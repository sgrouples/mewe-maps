// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mewe_maps/models/user.dart';

class UserPosition {
  final User user;
  final Position position;
  final DateTime timestamp;
  final DateTime? shareUntil;

  UserPosition({required this.user, required this.position, required this.timestamp, this.shareUntil});

  GeoPoint get geoPoint => GeoPoint(latitude: position.latitude, longitude: position.longitude);
}
