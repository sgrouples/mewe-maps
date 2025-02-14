import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mewe_maps/services/http/model/cdn_access_params.dart';

part 'auth_data.g.dart';

@JsonSerializable()
class AuthData extends Equatable {
  final String accessToken;
  final int expires;
  final int expiresIn;
  final String refreshToken;
  final int refreshTokenExpires;
  final CdnAccessParams cdnAccessParams;

  const AuthData(
      {required this.accessToken,
      required this.expires,
      required this.expiresIn,
      required this.refreshToken,
      required this.refreshTokenExpires,
      required this.cdnAccessParams});

  @override
  List<Object?> get props => [accessToken, expires, expiresIn, refreshToken, refreshTokenExpires, cdnAccessParams];

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}
