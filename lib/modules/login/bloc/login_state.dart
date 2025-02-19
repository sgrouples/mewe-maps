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

@CopyWith()
class LoginState extends Equatable {
  const LoginState(
      {required this.emailOrPhoneNumber,
      required this.password,
      required this.error,
      required this.isLoading,
      required this.user,
      required this.challenge});

  final String emailOrPhoneNumber;
  final String password;
  final String error;
  final bool isLoading;
  final User? user;
  final String? challenge;

  @override
  List<Object?> get props =>
      [emailOrPhoneNumber, password, error, user, isLoading, challenge];
}
