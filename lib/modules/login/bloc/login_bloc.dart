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
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/repositories/authentication/authentication_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/services/http/model/signin_response.dart';
import 'package:mewe_maps/utils/logger.dart';

part 'login_bloc.g.dart';
part 'login_event.dart';
part 'login_state.dart';

const _TAG = 'LoginBloc';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationRepository _authenticationRepository;

  LoginBloc(this._authenticationRepository) : super(const LoginState(emailOrPhoneNumber: "", error: "", isLoading: false, user: null)) {
    on<EmailOrPhoneNumberChanged>(_emailOrPhoneNumberChanged);
    on<LoginSubmitted>(_loginSubmitted);
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

  void _loginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    if (state.emailOrPhoneNumber.isEmpty) {
      emit(state.copyWith(error: "Email / Phone Number cannot be empty"));
    } else {
      emit(state.copyWith(isLoading: true));
      try {
        final User user = await _login();
        emit(state.copyWith(error: "", user: user));
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
          emit(state.copyWith(error: "Connection timeout. Please try again.", isLoading: false));
        } else {
          emit(state.copyWith(error: e.toString(), isLoading: false));
        }
      } catch (error) {
        emit(state.copyWith(error: error.toString(), isLoading: false));
      }
    }
  }

  Future<User> _login() async {
    String emailOrPhoneNumber = state.emailOrPhoneNumber;
    final SigninResponse tokenResponse = await _authenticationRepository.signIn(emailOrPhoneNumber);
    StorageRepository.setToken(tokenResponse.loginRequestToken);
    final User userResponse = await _authenticationRepository.getMyUser();
    StorageRepository.setUser(userResponse);
    return userResponse;
  }
}
