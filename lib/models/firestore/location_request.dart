// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mewe_maps/services/firebase/firestore_timestamp_adapter.dart';

part 'location_request.g.dart';

@JsonSerializable()
class LocationRequest extends Equatable {

  @JsonKey(includeToJson: false)
  final String? id;

  @JsonKey(name: 'requesting_user_id')
  final String requestingUserId;

  @JsonKey(name: 'requested_user_id')
  final String requestedUserId;

  @JsonKey(name: "requested_at")
  @TimestampConverter()
  final DateTime requestedAt;

  const LocationRequest({this.id, required this.requestingUserId, required this.requestedUserId, required this.requestedAt});

  @override
  List<Object?> get props => [id, requestingUserId, requestedUserId, requestedAt];

  factory LocationRequest.fromJson(String id, Map<String, dynamic> json) => _$LocationRequestFromJson(json..addAll({"id": id}));

  Map<String, dynamic> toJson() => _$LocationRequestToJson(this);

}
