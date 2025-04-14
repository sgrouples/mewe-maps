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
import 'package:mewe_maps/models/profile_photo.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  @JsonKey(name: "userId")
  final String userId;

  @JsonKey(name: "name")
  final String name;

  @JsonKey(name: "handle")
  final String handle;

  @JsonKey(name: "profilePhoto")
  final ProfilePhoto profilePhoto;

  const User({required this.userId, required this.name, required this.handle, required this.profilePhoto});

  bool isMe() {
    return userId == StorageRepository.user?.userId;
  }

  @override
  List<Object?> get props => [userId, name, handle, profilePhoto];

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
