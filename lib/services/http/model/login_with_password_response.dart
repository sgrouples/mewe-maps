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
