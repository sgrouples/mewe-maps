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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mewe_maps/models/firestore/firestore_constants.dart';
import 'package:mewe_maps/utils/logger.dart';

class FirebaseCloudMessagingRepository {
  static const String _TAG = "FirebaseCloudMessagingRepository";

  StreamSubscription? _subscription;

  void observeTokenForUser(String userId) {
    _subscription = FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      FirebaseFirestore.instance.collection(FirestoreConstants.COLLECTION_USERS_PRIVATE_DATA).doc(userId).set({"fcm_token": fcmToken});
    }, onError: (e) {
      Logger.log(_TAG, "Error observing FCM token: $e");
    });
  }

  Future<void> close() async {
    await _subscription?.cancel();
  }
}
