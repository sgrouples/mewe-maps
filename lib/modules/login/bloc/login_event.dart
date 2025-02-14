part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {}

class EmailOrPhoneNumberChanged extends LoginEvent {
  final String emailOrPhoneNumber;

  EmailOrPhoneNumberChanged(this.emailOrPhoneNumber);

  @override
  List<Object?> get props => [emailOrPhoneNumber];
}

class PasswordChanged extends LoginEvent {
  final String password;

  PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends LoginEvent {
  @override
  List<Object?> get props => ['LoginSubmitted'];
}

class ChallengeSubmitted extends LoginEvent {
  final String challenge;
  final String? challengeToken;

  ChallengeSubmitted(this.challenge, this.challengeToken);

  @override
  List<Object?> get props => [challenge, challengeToken];
}
