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
import 'package:mewe_maps/utils/logger.dart';

class FirebaseCloudMessagingRepository {
  static const String _TAG = "FirebaseCloudMessagingRepository";
  static const String _COLLECTION_FCM_TOKENS = "fcmtokens";

  StreamSubscription? _subscription;

  void observeTokenForUser(String userId) {
    _subscription = FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      FirebaseFirestore.instance.collection(_COLLECTION_FCM_TOKENS).doc(userId).set({"token": fcmToken});
    }, onError: (e) {
      Logger.log(_TAG, "Error observing FCM token: $e");
    });
  }

  void close() {
    _subscription?.cancel();
  }
}
