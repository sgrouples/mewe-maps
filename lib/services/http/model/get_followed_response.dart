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
import 'package:mewe_maps/models/followed.dart';

part 'get_followed_response.g.dart';

@JsonSerializable()
class GetFollowedResponse extends Equatable {
  final List<Followed> list;

  final String? nextPage;

  const GetFollowedResponse({
    required this.list,
    this.nextPage,
  });

  @override
  List<Object?> get props => [list, nextPage];

  factory GetFollowedResponse.fromJson(Map<String, dynamic> json) => _$GetFollowedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetFollowedResponseToJson(this);
}
