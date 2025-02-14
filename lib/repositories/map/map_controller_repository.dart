import 'dart:io';
import 'dart:math';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mewe_maps/models/user_position.dart';
import 'package:mewe_maps/modules/map/view/components/marker_user.dart';
import 'package:mewe_maps/services/http/image_downloader.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:synchronized/synchronized.dart';

const _TAG = 'MapControllerRepository';

class MapControllerRepository {
  late final ImageDownloader _imageDownloader;

  late MapController mapController = Platform.isIOS
      ? MapController.withUserPosition()
      : MapController.withPosition(initPosition: GeoPoint(latitude: 0, longitude: 0));

  final _lock = Lock();

  UserPosition? myPosition;
  List<UserPosition> contactsPositions = [];

  MapControllerRepository(this._imageDownloader);

  void displayMyPosition(UserPosition? newPosition) {
    _lock.synchronized(() async {
      UserPosition? currentPosition = myPosition;

      if (currentPosition != null && newPosition == null) {
        await mapController.removeMarker(currentPosition.geoPoint);
      } else if (currentPosition == null && newPosition != null) {
        await mapController.setZoom(zoomLevel: 13, stepZoom: 1);
        await mapController.moveTo(newPosition.geoPoint);
        await _addMarker(newPosition);
      } else if (currentPosition != null && newPosition != null && currentPosition.geoPoint != newPosition.geoPoint) {
        await mapController.changeLocationMarker(oldLocation: currentPosition.geoPoint, newLocation:  newPosition.geoPoint);
      }
      myPosition = newPosition;
    });
  }

  void displayContactsPositions(List<UserPosition> newPositions) {
    _lock.synchronized(() async {
      List<UserPosition> currentPositions = contactsPositions;
      for (final position in newPositions) {
        final currentPosition = currentPositions.firstOrNullWhere((it) => it.user.userId == position.user.userId);
        if (currentPosition == null || currentPosition.geoPoint != position.geoPoint) {
          if (currentPosition != null) {
            await mapController.changeLocationMarker(oldLocation: currentPosition.geoPoint, newLocation: position.geoPoint);
            contactsPositions.remove(currentPosition);
          } else {
            await _addMarker(position);
          }
          contactsPositions.add(position);
        }
      }
      for (final it in currentPositions) {
        if (newPositions.firstOrNullWhere((it2) => it2.user.userId == it.user.userId) == null) {
          await mapController.removeMarker(it.geoPoint);
          contactsPositions.remove(it);
        }
      }
    });
  }

  UserPosition? findUserPosition(GeoPoint point) {
    UserPosition? myPosition = this.myPosition;
    List<UserPosition> contactsPositions = this.contactsPositions;

    if (myPosition != null && myPosition.geoPoint == point) {
      return myPosition;
    }

    for (var position in contactsPositions) {
      if (position.geoPoint == point) {
        return position;
      }
    }

    return null;
  }

  UserPosition? findUserPositionByUserId(String userId) {
    UserPosition? myPosition = this.myPosition;
    List<UserPosition> contactsPositions = this.contactsPositions;

    if (myPosition != null && myPosition.user.userId == userId) {
      return myPosition;
    }

    for (var position in contactsPositions) {
      if (position.user.userId == userId) {
        return position;
      }
    }

    return null;
  }

  void moveToPosition(UserPosition position) {
    _lock.synchronized(() async {
      await mapController.moveTo(position.geoPoint);
    });
  }

  Future<void> _addMarker(UserPosition position) async {
    String avatarUlr = position.user.halLinks.getAvatarUrl();

    MemoryImage? avatarImage;

    if (avatarUlr.isNotEmpty) {
      // Download the image before adding a marker to the map, as the map does not update widgets when they are updated concurrently
      avatarImage = await _imageDownloader.downloadImage(avatarUlr);
    }

    await mapController.addMarker(
      position.geoPoint,
      markerIcon: MarkerIcon(
        iconWidget: MarkerUser(
          user: position.user,
          customImage: avatarImage,
        ),
      ),
      angle: pi / 3,
      iconAnchor: IconAnchor(
        anchor: Anchor.center,
      ),
    );
  }
}
