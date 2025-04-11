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

part 'get_token_response.g.dart';

@JsonSerializable()
class GetTokenResponse extends Equatable {
  final bool? pending;
  final String? expiresAt;
  final String? token;

  const GetTokenResponse({this.pending, this.expiresAt, this.token});

  @override
  List<Object?> get props => [pending, expiresAt, token];

  factory GetTokenResponse.fromJson(Map<String, dynamic> json) => _$GetTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetTokenResponseToJson(this);
}
