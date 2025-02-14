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
