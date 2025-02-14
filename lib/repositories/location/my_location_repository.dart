import 'dart:async';

import 'package:background_location_tracker/background_location_tracker.dart' as blt;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mewe_maps/isolates.dart';
import 'package:mewe_maps/services/location/location_sharing.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

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
    await shareMyLocationWithSessions(true);
  });
}

class MyLocationRepositoryImpl implements MyLocationRepository {

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  @override
  Future<Position?> getLastKnownPosition() async {
    if (await _handlePermission()) {
      return Geolocator.getLastKnownPosition();
    } else {
      throw Exception('Permission denied');
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
              )
          ),
        );
        await blt.BackgroundLocationTrackerManager.startTracking();
        Logger.log(_TAG, "precise tracking started");
      } else {
        Logger.log(_TAG, "already tracking precise location");
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
    } else {
      throw Exception('Permission denied');
    }
  }

  @override
  Future<void> cancelObservingPrecisePosition() {
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
    if (defaultTargetPlatform == TargetPlatform.android &&
        await Permission.notification.isDenied) {
      PermissionStatus permission = await Permission.notification.request();
      if (permission.isDenied) {
        return false;
      }
    }
    LocationPermission permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
