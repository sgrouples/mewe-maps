// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartx/dartx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mewe_maps/models/contact_sharing_data.dart';
import 'package:mewe_maps/models/firestore/share_data.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/models/firestore/sharing_session.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

abstract class SharingLocationRepository {
  // Start sharing my position with the given user ids.
  // Time interval is in minutes.
  // sharingUser - data of the user who wants to share the location.
  Future<void> startSharingSession(
      User sharingUser, User recipientUser, int shareMinutes, bool isPrecise);

  // Stop sharing my position with the given session id.
  Future<void> stopSharingSession(String sessionId);

  // Observe the sharing sessions where user is the owner (provides location to others).
  Stream<List<SharingSession>> observeSharingSessionsAsOwner(String userId);

  // Get the sharing sessions where user is the owner (provides location to others).
  Future<List<SharingSession>?> getSharingSessionsAsOwner(String userId);

  // Upload my position to the server.
  Future<void> uploadPosition(Position position, List<SharingSession> sessions);

  // Observe the positions of contacts' who share location with user.
  Stream<List<ContactSharingData>> observeContactsSharingData(String userId);
}

const _TAG = 'FirestoreSharingLocationRepository';
const TIME_INTERVAL_FOREVER = -1;
const SHARING_SESSION_COLLECTION = 'sharing_sessions';
const SHARED_DATA_COLLECTION = 'shared_data';
final MAX_SHARE_UNTIL = DateTime(9999, 12, 31);

class FirestoreSharingLocationRepository implements SharingLocationRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<List<SharingSession>?> getSharingSessionsAsOwner(String userId) {
    return _firestore
        .collection(SHARING_SESSION_COLLECTION)
        .where('owner_id', isEqualTo: userId)
        .where("share_until", isGreaterThan: Timestamp.now())
        .get()
        .then((value) {
      return value.docs
          .map((e) => SharingSession.fromJson(e.id, e.data()))
          .toList();
    });
  }

  @override
  Stream<List<ContactSharingData>> observeContactsSharingData(String userId) {
    return CombineLatestStream.combine2(
        _firestore
            .collection(SHARING_SESSION_COLLECTION)
            .where('recipient_id', isEqualTo: userId)
            .where("share_until", isGreaterThan: Timestamp.now())
            .snapshots()
            .map((sessions) => sessions.docs
                .map((e) => SharingSession.fromJson(e.id, e.data()))
                .toList()),
        _firestore
            .collection(SHARED_DATA_COLLECTION)
            .where('recipient_id', isEqualTo: userId)
            .snapshots()
            .map((sharedData) => sharedData.docs
                .map((e) => ShareData.fromJson(e.id, e.data()))
                .toList()), (sessions, sharedData) {
      final (cleanedSharedData, cleanedSessions) = _cleanUpOldData(sharedData, sessions);

      return cleanedSessions
          .map((session) {
            final data = cleanedSharedData
                .firstOrNullWhere((element) => element.sessionId == session.id);
            if (data == null) return null;
            return ContactSharingData(
              id: session.id,
              contactId: session.ownerId,
              contact: User.fromJson(jsonDecode(session.ownerDataRaw)),
              shareUntil: session.shareUntil,
              position: Position.fromMap(jsonDecode(data.positionDataRaw)),
              updatedAt: data.updatedAt,
            );
          })
          .nonNulls
          .toList();
    });
  }

  @override
  Stream<List<SharingSession>> observeSharingSessionsAsOwner(String userId) {
    return _firestore
        .collection(SHARING_SESSION_COLLECTION)
        .where('owner_id', isEqualTo: userId)
        .where("share_until", isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snapshot) {
      final sessions = snapshot.docs
          .map((e) => SharingSession.fromJson(e.id, e.data()))
          .toList();
      return _cleanUpOldSessions(sessions);
    });
  }

  @override
  Future<void> startSharingSession(User sharingUser, User recipientUser,
      int shareMinutes, bool isPrecise) async {
    await _deleteOldSessionForUsers(sharingUser, recipientUser);

    return await _firestore.collection(SHARING_SESSION_COLLECTION).add({
      'owner_id': sharingUser.userId,
      'recipient_id': recipientUser.userId,
      'recipient_user_data': jsonEncode(recipientUser.toJson()),
      'owner_user_data': jsonEncode(sharingUser.toJson()),
      'share_until': shareMinutes == TIME_INTERVAL_FOREVER
          ? MAX_SHARE_UNTIL
          : DateTime.now().add(Duration(minutes: shareMinutes)),
      'is_precise': isPrecise,
    }).then((value) {
      Logger.log(_TAG, 'Sharing session started with id: ${value.id}');
    });
  }

  Future<void> _deleteOldSessionForUsers(User sharingUser, User recipientUser) {
    return _firestore
        .collection(SHARING_SESSION_COLLECTION)
        .where('owner_id', isEqualTo: sharingUser.userId)
        .where('recipient_id', isEqualTo: recipientUser.userId)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        await element.reference.delete();
        await _firestore
            .collection(SHARED_DATA_COLLECTION)
            .doc(element.id)
            .delete();
      });
    });
  }

  @override
  Future<void> stopSharingSession(String sessionId) {
    return _firestore
        .collection(SHARING_SESSION_COLLECTION)
        .doc(sessionId)
        .delete();
  }

  @override
  Future<void> uploadPosition(
      Position position, List<SharingSession> sessions) {
    Logger.log(_TAG, 'Uploading position to ${sessions.length} sessions');
    List<Future> futures = [];
    for (var session in sessions) {
      final data = ShareData(
        sessionId: session.id,
        recipientId: session.recipientId,
        positionDataRaw: jsonEncode(position.toJson()),
        updatedAt: DateTime.now(),
      );
      futures.add(_firestore
          .collection(SHARED_DATA_COLLECTION)
          .doc(data.sessionId)
          .set(data.toJson()));
    }
    return Future.value();
  }

  List<SharingSession> _cleanUpOldSessions(List<SharingSession> sessions) {
    final now = DateTime.now();
    List<SharingSession> newSessions = [];
    for (var session in sessions) {
      if (session.shareUntil.isBefore(now)) {
        _firestore
            .collection(SHARING_SESSION_COLLECTION)
            .doc(session.id)
            .delete();
      } else {
        newSessions.add(session);
      }
    }
    return newSessions;
  }

  (List<ShareData>, List<SharingSession>) _cleanUpOldData(
      List<ShareData> sharedData, List<SharingSession> sessions) {
    sessions = _cleanUpOldSessions(sessions);
    List<ShareData> newSharedData = [];
    for (var data in sharedData) {
      if (sessions.none((element) => element.id == data.sessionId)) {
        _firestore
            .collection(SHARED_DATA_COLLECTION)
            .doc(data.sessionId)
            .delete();
      } else {
        newSharedData.add(data);
      }
    }
    return (newSharedData, sessions);
  }
}
