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

import 'package:geolocator/geolocator.dart';
import 'package:mewe_maps/models/contact_sharing_data.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/models/user_sharing_session.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

abstract class SharingLocationRepository {
  // Start sharing my position with the given user ids.
  // Time interval is in minutes.
  // sharingUser - data of the user who wants to share the location.
  Future<void> startSharingSession(
      User sharingUser, User recipientUser, int shareMinutes, bool isPrecise);

  // Stop sharing my position with the given session id.
  Future<void> stopSharingSession(int sessionId);

  // Observe the sharing sessions where user is the owner (provides location to others).
  Stream<List<UserSharingSession>> observeSharingSessionsAsOwner(String userId);

  // Get the sharing sessions where user is the owner (provides location to others).
  Future<List<UserSharingSession>?> getSharingSessionsAsOwner(String userId);

  // Upload my position to the server.
  Future<void> uploadPosition(
      Position position, List<UserSharingSession> sessions);

  // Observe the positions of contacts' who share location with user.
  Stream<List<ContactSharingData>> observeContactsSharingData(String userId);
}

const _TAG = 'SupabaseSharingLocationRepository';
const TIME_INTERVAL_FOREVER = -1;
final MAX_SHARE_UNTIL = DateTime(9999, 12, 31);

class SupabaseSharingLocationRepository implements SharingLocationRepository {
  final _supabase = Supabase.instance.client;

  @override
  Stream<List<ContactSharingData>> observeContactsSharingData(String userId) {
    final controller = StreamController<List<ContactSharingData>>();

    Future<void> fetchData() async {
      while (!controller.isClosed) {
        // Keep fetching while the stream is open
        final data = await _getContactsSharingData(userId);
        if (data != null) {
          controller.add(data);
        }
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    fetchData(); // Start the background loop

    controller.onCancel = () {
      controller.close(); // Close the stream when no more listeners exist
    };

    return controller.stream;
  }

  Future<List<ContactSharingData>?> _getContactsSharingData(
      String userId) async {
    try {
      final response = await _supabase
          .from("sharing_sessions")
          .select(
              'id, owner_id, owner_user_data, share_until, shared_data(location_data, updated_at)')
          .eq('recipient_id', userId)
          .gte('share_until', DateTime.now().toIso8601String());

      return response
          .map((element) => ContactSharingData.fromJson(element))
          .toList();
    } catch (e) {
      Logger.log(_TAG, 'Error while fetching contacts sharing data. $e');
      return null;
    }
  }

  @override
  Stream<List<UserSharingSession>> observeSharingSessionsAsOwner(
      String userId) {
    final controller = StreamController<List<UserSharingSession>>.broadcast();

    Future<void> fetchData() async {
      while (!controller.isClosed) {
        // Keep fetching while the stream is open
        final data = await getSharingSessionsAsOwner(userId);
        if (data != null) {
          controller.add(data);
        }
        await Future.delayed(
            const Duration(seconds: 5)); // Wait before fetching again
      }
    }

    fetchData(); // Start the background loop

    controller.onCancel = () {
      controller.close(); // Close the stream when no more listeners exist
    };

    return controller.stream;
  }

  @override
  Future<List<UserSharingSession>?> getSharingSessionsAsOwner(
      String userId) async {
    try {
      final response = await _supabase
          .from("sharing_sessions")
          .select(
              'id, recipient_id, recipient_user_data, share_until, is_precise')
          .eq('owner_id', userId)
          .gte('share_until', DateTime.now().toIso8601String());

      return response
          .map((element) => UserSharingSession.fromJson(element))
          .toList();
    } catch (e) {
      Logger.log(_TAG, 'Error while fetching user sharing session. $e');
      return null;
    }
  }

  @override
  Future<void> startSharingSession(User sharingUser, User recipientUser,
      int shareMinutes, bool isPrecise) async {
    Logger.log(_TAG,
        'user: $sharingUser, recipient: $recipientUser, shareMinutes: $shareMinutes, isPrecise: $isPrecise');
    await _supabase
        .from('sharing_sessions')
        .delete()
        .eq('owner_id', sharingUser.userId)
        .eq('recipient_id', recipientUser.userId);

    final now = DateTime.now();
    final shareUntil = shareMinutes == TIME_INTERVAL_FOREVER
        ? MAX_SHARE_UNTIL
        : now.add(Duration(minutes: shareMinutes)); // Add interval

    final data = {
      'owner_id': sharingUser.userId,
      'recipient_id': recipientUser.userId,
      'recipient_user_data': jsonEncode(recipientUser.toJson()),
      'owner_user_data': jsonEncode(sharingUser.toJson()),
      'share_until': shareUntil.toIso8601String(),
      'created_at': now.toIso8601String(),
      'is_precise': isPrecise,
    };

    return _supabase.from('sharing_sessions').upsert(data);
  }

  @override
  Future<void> stopSharingSession(int sessionId) {
    Logger.log(_TAG, 'stopSharingSession: $sessionId');
    return _supabase.from('sharing_sessions').delete().eq('id', sessionId);
  }

  @override
  Future<void> uploadPosition(
      Position position, List<UserSharingSession> sessions) {
    try {
      List<Future> futures = [];
      for (var session in sessions) {
        final data = {
          'id': session.id,
          'location_data': jsonEncode(position.toJson()),
          'updated_at': DateTime.now().toIso8601String(),
        };
        futures.add(_supabase.from('shared_data').upsert(data));
      }
      return Future.wait(futures);
    } catch (e) {
      Logger.log(_TAG, 'Error while uploading position. $e');
      return Future.error(e);
    }
  }
}
