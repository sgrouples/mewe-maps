// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mewe_maps/models/user_position.dart';
import 'package:mewe_maps/modules/map/view/components/marker_user.dart';
import 'package:mewe_maps/services/http/image_downloader.dart';
import 'package:synchronized/synchronized.dart';

class MapControllerManager {
  final mapController = MapController(
    initMapWithUserPosition: const UserTrackingOption(enableTracking: false),
  );

  final VoidCallback? onMapSingleTap;
  final Function(UserPosition)? onUserTap;

  final ImageDownloader _imageDownloader;

  MapControllerManager(this._imageDownloader,
      {this.onMapSingleTap, this.onUserTap}) {
    mapController.listenerMapSingleTapping.addListener(() {
      onMapSingleTap?.call();
    });
  }

  UserPosition? myPosition;
  final List<UserPosition> _contactsPositions = [];
  UserPosition? _trackedUser;

  final _lock = Lock();

  void setContactsPositions(List<UserPosition> newPositions) {
    _lock.synchronized(() async {
      final currentPositions = _contactsPositions;
      for (final position in newPositions) {
        final currentPosition = currentPositions
            .firstOrNullWhere((it) => it.user.userId == position.user.userId);
        if (currentPosition == null ||
            currentPosition.geoPoint != position.geoPoint) {
          if (currentPosition != null) {
            await mapController.changeLocationMarker(
              oldLocation: currentPosition.geoPoint,
              newLocation: position.geoPoint,
            );
            _contactsPositions.remove(currentPosition);
          } else {
            await _addMarker(position);
          }
          _contactsPositions.add(position);
          if (_trackedUser?.user.userId == position.user.userId) {
            mapController.moveTo(position.geoPoint, animate: true);
          }
        }
      }
    });
  }

  void setMyPosition(UserPosition? newPosition) {
    _lock.synchronized(() async {
      UserPosition? currentPosition = myPosition;

      if (currentPosition != null && newPosition == null) {
        await mapController.removeMarker(currentPosition.geoPoint);
      } else if (currentPosition == null && newPosition != null) {
        await mapController.setZoom(zoomLevel: 13, stepZoom: 1);
        await mapController.moveTo(newPosition.geoPoint);
        await _addMarker(newPosition);
      } else if (currentPosition != null &&
          newPosition != null &&
          currentPosition.geoPoint != newPosition.geoPoint) {
        await mapController.changeLocationMarker(
            oldLocation: currentPosition.geoPoint,
            newLocation: newPosition.geoPoint);
      }
      myPosition = newPosition;
      if (_trackedUser != null &&
          _trackedUser?.user.userId == myPosition?.user.userId) {
        mapController.moveTo(myPosition!.geoPoint, animate: true);
      }
    });
  }

  void tapGeopoint(GeoPoint geoPoint) {
    final tappedUser =
        _contactsPositions.firstOrNullWhere((it) => it.geoPoint == geoPoint);
    if (tappedUser != null) {
      onUserTap?.call(tappedUser);
    } else {
      onMapSingleTap?.call();
    }
    mapController.moveTo(geoPoint, animate: true);
  }

  void moveToUser(UserPosition userPosition) {
    mapController.moveTo(userPosition.geoPoint, animate: true);
  }

  void setTrackingUser(UserPosition? userPosition) {
    _trackedUser = userPosition;
    if (userPosition != null) {
      mapController.moveTo(userPosition.geoPoint, animate: true);
    }
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

  void dispose() {
    mapController.dispose();
  }
}
