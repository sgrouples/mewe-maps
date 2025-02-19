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
import 'package:mewe_maps/models/hal_link.dart';
import 'package:mewe_maps/services/http/auth_constants.dart';

part 'hal_links.g.dart';

@JsonSerializable()
class HalLinks extends Equatable {
  @JsonKey(name: "avatar")
  final HalLink? avatar;

  @JsonKey(name: "nextPage")
  final HalLink? nextPage;

  const HalLinks({this.avatar, this.nextPage});

  @override
  List<Object?> get props => [avatar, nextPage];

  String getAvatarUrl() {
    final String url = avatar!.href;
    if (url.startsWith("https://")) {
      return url;
    } else if (url.isEmpty) {
      return "";
    } else {
      return AuthConfig.meweImageHost +
          url.replaceAll("{imageSize}", "400x400");
    }
  }

  factory HalLinks.fromJson(Map<String, dynamic> json) =>
      _$HalLinksFromJson(json);

  Map<String, dynamic> toJson() => _$HalLinksToJson(this);
}
