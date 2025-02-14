import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_with_password_request.g.dart';

@JsonSerializable()
class LoginWithPasswordRequest extends Equatable {
  const LoginWithPasswordRequest({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object> get props => [username, password];

  factory LoginWithPasswordRequest.fromJson(Map<String, dynamic> json) => _$LoginWithPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginWithPasswordRequestToJson(this);
}
