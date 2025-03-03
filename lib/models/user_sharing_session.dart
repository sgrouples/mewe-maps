// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_sharing_session.g.dart';

@JsonSerializable()
class UserSharingSession extends Equatable {
  @JsonKey(name: "id")
  final int id;

  @JsonKey(name: "recipient_id")
  final String recipientId;

  @JsonKey(name: "recipient_user_data")
  final String recipientDataRaw;

  @JsonKey(name: "share_until")
  final DateTime shareUntil;

  @JsonKey(name: "is_precise")
  final bool isPrecise;

  @override
  List<Object?> get props => [id, recipientId, recipientDataRaw, shareUntil, isPrecise];

  const UserSharingSession({required this.id, required this.recipientId, required this.recipientDataRaw, required this.shareUntil, required this.isPrecise});

  factory UserSharingSession.fromJson(Map<String, dynamic> json) => _$UserSharingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$UserSharingSessionToJson(this);
}
