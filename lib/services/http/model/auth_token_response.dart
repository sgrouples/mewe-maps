import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mewe_maps/models/auth_data.dart';
import 'package:mewe_maps/services/http/model/cdn_access_params.dart';

part 'auth_token_response.g.dart';

@JsonSerializable()
class AuthTokenResponse extends Equatable {
  final String accessToken;
  final int expires;
  final int expiresIn;
  final String refreshToken;
  final int refreshTokenExpires;
  final CdnAccessParams cdnAccessParams;

  const AuthTokenResponse(
      {required this.accessToken,
      required this.expires,
      required this.expiresIn,
      required this.refreshToken,
      required this.refreshTokenExpires,
      required this.cdnAccessParams});

  @override
  List<Object?> get props => [accessToken, expires, expiresIn, refreshToken, refreshTokenExpires, cdnAccessParams];

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

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) => _$AuthTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenResponseToJson(this);
}
