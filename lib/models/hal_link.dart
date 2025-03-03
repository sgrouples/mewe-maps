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

part 'hal_link.g.dart';

@JsonSerializable()
class HalLink extends Equatable {
  @JsonKey(name: "href")
  final String href;

  const HalLink({required this.href});

  @override
  List<Object?> get props => [href];

  factory HalLink.fromJson(Map<String, dynamic> json) => _$HalLinkFromJson(json);

  Map<String, dynamic> toJson() => _$HalLinkToJson(this);
}
