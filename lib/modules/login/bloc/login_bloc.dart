// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/repositories/authentication/authentication_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/services/http/model/challenges_response.dart';
import 'package:mewe_maps/services/http/model/login_with_password_response.dart';
import 'package:mewe_maps/utils/logger.dart';

part 'login_bloc.g.dart';
part 'login_event.dart';
part 'login_state.dart';

const _TAG = 'LoginBloc';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationRepository _authenticationRepository;

  LoginBloc(this._authenticationRepository)
      : super(const LoginState(emailOrPhoneNumber: "", password: "", error: "", isLoading: false, user: null, challenge: null)) {
    on<EmailOrPhoneNumberChanged>(_emailOrPhoneNumberChanged);
    on<PasswordChanged>(_passwordChanged);
    on<LoginSubmitted>(_loginSubmitted);
    on<ChallengeSubmitted>(_challengeSubmitted);
  }

  @override
  void onEvent(LoginEvent event) {
    super.onEvent(event);
    Logger.log(_TAG, "event ${event.toString()}");
    Logger.log(_TAG, "state ${state.toString()}");
  }

  void _emailOrPhoneNumberChanged(EmailOrPhoneNumberChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(emailOrPhoneNumber: event.emailOrPhoneNumber));
  }

  void _passwordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(password: event.password));
  }

  void _loginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    if (state.emailOrPhoneNumber.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(error: "Email / Phone Number and Password cannot be empty"));
    } else {
      emit(state.copyWith(isLoading: true));
      try {
        final challengesResponse = await _authenticationRepository.getChallenges();
        if (challengesResponse.challenges.contains(ChallengesResponse.challengeCaptcha)) {
          emit(state.copyWith(challenge: ChallengesResponse.challengeCaptcha));
        } else if (challengesResponse.challenges.contains(ChallengesResponse.challengeArkose)) {
          emit(state.copyWith(challenge: ChallengesResponse.challengeArkose));
        } else {
          final LoginWithPasswordResponse loginResponse = await _login(null, null);
          emit(state.copyWith(error: "", user: loginResponse.user));
        }
      } catch (error) {
        emit(state.copyWith(error: error.toString(), isLoading: false));
      }
    }
  }

  void _challengeSubmitted(ChallengeSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(challenge: null));
    try {
      final LoginWithPasswordResponse loginResponse = await _login(event.challenge, event.challengeToken);
      emit(state.copyWith(error: "", user: loginResponse.user));
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  Future<LoginWithPasswordResponse> _login(String? challenge, String? challengeToken) async {
    String emailOrPhoneNumber = state.emailOrPhoneNumber;
    String password = state.password;
    final LoginWithPasswordResponse loginResponse;
    if (emailOrPhoneNumber.contains('@')) {
      loginResponse = await _authenticationRepository.loginByEmail(emailOrPhoneNumber, password, challenge, challengeToken);
    } else {
      loginResponse = await _authenticationRepository.loginByNumber(emailOrPhoneNumber, password, challenge, challengeToken);
    }
    StorageRepository.setUser(loginResponse.user);
    StorageRepository.setAuthData(loginResponse.getAuthData());
    return loginResponse;
  }
}
