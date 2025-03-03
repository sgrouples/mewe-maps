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
import 'package:mewe_maps/models/auth_data.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/services/http/model/cdn_access_params.dart';

part 'login_with_password_response.g.dart';

@JsonSerializable()
class LoginWithPasswordResponse extends Equatable {
  final User user;

  final String accessToken;
  final int expires;
  final int expiresIn;
  final String refreshToken;
  final int refreshTokenExpires;
  final CdnAccessParams cdnAccessParams;

  const LoginWithPasswordResponse(
      {required this.user,
      required this.accessToken,
      required this.expires,
      required this.expiresIn,
      required this.refreshToken,
      required this.refreshTokenExpires,
      required this.cdnAccessParams});

  @override
  List<Object?> get props => [user, accessToken, expires, expiresIn, refreshToken, refreshTokenExpires, cdnAccessParams];

  AuthData getAuthData() {
    return AuthData(
      accessToken: accessToken,
      expires: expires,
      expiresIn: expiresIn,
      refreshToken: refreshToken,
      refreshTokenExpires: refreshTokenExpires,
      cdnAccessParams: cdnAccessParams,
    );
  }

  factory LoginWithPasswordResponse.fromJson(Map<String, dynamic> json) => _$LoginWithPasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginWithPasswordResponseToJson(this);
}
