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

part 'sharing_session.g.dart';

@JsonSerializable()
class SharingSession extends Equatable {
  @JsonKey(includeToJson: false)
  final String id;

  @JsonKey(name: "recipient_id")
  final String recipientId;

  @JsonKey(name: "recipient_user_data")
  final String recipientDataRaw;

  @JsonKey(name: "owner_id")
  final String ownerId;

  @JsonKey(name: "owner_user_data")
  final String ownerDataRaw;

  @JsonKey(name: "share_until")
  @TimestampConverter()
  final DateTime shareUntil;

  @JsonKey(name: "is_precise")
  final bool isPrecise;

  @override
  List<Object?> get props => [id, recipientId, recipientDataRaw, ownerId, ownerDataRaw, shareUntil, isPrecise];

  const SharingSession(
      {required this.id,
      required this.recipientId,
      required this.recipientDataRaw,
      required this.ownerId,
      required this.ownerDataRaw,
      required this.shareUntil,
      required this.isPrecise});

  factory SharingSession.fromJson(String id, Map<String, dynamic> json) => _$SharingSessionFromJson(json..addAll({"id": id}));

  Map<String, dynamic> toJson() => _$SharingSessionToJson(this);
}
