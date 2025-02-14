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
  List<Object?> get props => [emailOrPhoneNumber, password, error, user, isLoading, challenge];
}
