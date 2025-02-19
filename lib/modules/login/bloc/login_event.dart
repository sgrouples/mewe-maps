// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

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
