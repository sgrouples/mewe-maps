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

import 'package:background_location_tracker/background_location_tracker.dart' as blt;
import 'package:geolocator/geolocator.dart';
import 'package:mewe_maps/isolates.dart';
import 'package:mewe_maps/modules/app/app_lifecycle_tracker.dart';
import 'package:mewe_maps/services/location/location_sharing.dart';
import 'package:mewe_maps/services/permissions/permissions.dart';
import 'package:mewe_maps/utils/logger.dart';

abstract class MyLocationRepository {
  Future<Position?> getLastKnownPosition();

  Stream<Position> observePrecisePosition();

  Future<bool> isObservingPrecisePosition();

  Future<void> cancelObservingPrecisePosition();
}

const String _TAG = 'MyLocationRepositoryImpl';
const int PRECISE_TRACKING_INTERVAL_SEC = 10;
const int _LOCATION_DISTANCE_FILTER_METERS_IOS = 10;
const double _LOCATION_DISTANCE_FILTER_METERS_ANDROID = 10;

@pragma('vm:entry-point')
void backgroundLocationTrackerCallback() async {
  await initializeIsolate();

  blt.BackgroundLocationTrackerManager.handleBackgroundUpdated((data) async {
    if (!await shareMyLocationWithSessions() && !await AppLifecycleTracker.isAppVisible()) {
      Logger.log(_TAG, "stopTracking in backgroundLocationTrackerCallback");
      blt.BackgroundLocationTrackerManager.stopTracking();
    }
  });
}

class MyLocationRepositoryImpl implements MyLocationRepository {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  @override
  Future<Position?> getLastKnownPosition() async {
    try {
      if (await _handlePermission()) {
        return Geolocator.getLastKnownPosition();
      } else {
        Logger.log(_TAG, "Get last known location fails. Permission Denied");
        return null;
      }
    } catch (e) {
      Logger.log(_TAG, "Get last known location fails. $e");
      return null;
    }
  }

  @override
  Stream<Position> observePrecisePosition() async* {
    if (await _handlePermission()) {
      if (!await blt.BackgroundLocationTrackerManager.isTracking()) {
        await blt.BackgroundLocationTrackerManager.initialize(
          backgroundLocationTrackerCallback,
          config: const blt.BackgroundLocationTrackerConfig(
              loggingEnabled: true,
              androidConfig: blt.AndroidConfig(
                notificationIcon: 'ic_launcher',
                trackingInterval: Duration(seconds: PRECISE_TRACKING_INTERVAL_SEC),
                distanceFilterMeters: _LOCATION_DISTANCE_FILTER_METERS_ANDROID,
                enableCancelTrackingAction: false,
              ),
              iOSConfig: blt.IOSConfig(
                activityType: blt.ActivityType.FITNESS,
                distanceFilterMeters: _LOCATION_DISTANCE_FILTER_METERS_IOS,
                restartAfterKill: true,
              )),
        );
        await blt.BackgroundLocationTrackerManager.startTracking();
        Logger.log(_TAG, "Precise tracking started");
      } else {
        Logger.log(_TAG, "Already tracking precise location");
      }

      Position? initialPosition = await getLastKnownPosition();
      if (initialPosition != null) {
        yield initialPosition;
      }

      yield* Stream.periodic(const Duration(seconds: PRECISE_TRACKING_INTERVAL_SEC), (_) => getLastKnownPosition())
          .asyncMap((futurePosition) async => await futurePosition)
          .where((position) => position != null)
          .cast<Position>()
          .distinct();
    }
  }

  @override
  Future<void> cancelObservingPrecisePosition() {
    Logger.log(_TAG, "Precise tracking stopped");
    return blt.BackgroundLocationTrackerManager.stopTracking();
  }

  @override
  Future<bool> isObservingPrecisePosition() {
    return blt.BackgroundLocationTrackerManager.isTracking();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    return await areAllPermissionsGranted();
  }
}
