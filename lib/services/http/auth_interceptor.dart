// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mewe_maps/models/auth_data.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/services/http/auth_constants.dart';
import 'package:mewe_maps/services/http/dio_client.dart';
import 'package:mewe_maps/services/http/model/auth_token_response.dart';

class AuthInterceptor extends Interceptor {
  static const String _AUTH_KEY = 'Authorization';
  static const String _COOKIE = 'Cookie';
  static const String _COOKIE_AUTH_HEADER = '@CookieAuth';
  static const String _NO_AUTH_HEADER = '@NoAuth';

  final Dio _tokenRefreshDio = DioClient.createDio();
  Completer? _tokenRefreshCompleter;

  AuthInterceptor() {
    _tokenRefreshDio.interceptors.add(this);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!isMeweRequest(options.uri.host) || isCookieAuth(options) || isNoAuth(options)) {
      options.headers.remove(_COOKIE_AUTH_HEADER);
      options.headers.remove(_NO_AUTH_HEADER);
      return handler.next(options);
    }

    if (options.uri.path.endsWith('/auth/login') || options.uri.path.endsWith('/account/challenges-available')) {
      return handler.next(options);
    }

    if (options.uri.path.endsWith('/auth/token')) {
      AuthData authData = StorageRepository.authData!;
      options.headers[_AUTH_KEY] = 'Sgrouples refreshToken=${authData.refreshToken}';
      return handler.next(options);
    }

    if (_tokenRefreshCompleter != null) {
      await _tokenRefreshCompleter?.future;
      _tokenRefreshCompleter = null;
      return onRequest(options, handler);
    }

    AuthData authData = StorageRepository.authData!;
    options.headers[_AUTH_KEY] = 'Sgrouples accessToken=${authData.accessToken}';
    options.headers[_COOKIE] = authData.cdnAccessParams.buildCdnCookie();

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _tokenRefreshCompleter = Completer<void>();
      try {
        final newAuthData = await refreshToken();
        StorageRepository.setAuthData(newAuthData);
        _tokenRefreshCompleter?.complete();
        final retryOptions = err.requestOptions;
        retryOptions.headers[_AUTH_KEY] = 'Sgrouples accessToken=${newAuthData.accessToken}';
        retryOptions.headers[_COOKIE] = newAuthData.cdnAccessParams.buildCdnCookie();
        final response = await _tokenRefreshDio.fetch(retryOptions);
        return handler.resolve(response);
      } catch (e) {
        _tokenRefreshCompleter?.completeError(e);
        return handler.next(err);
      } finally {
        _tokenRefreshCompleter = null;
      }
    }

    return handler.next(err);
  }

  bool isMeweRequest(String host) {
    return host.endsWith("mewe.com") || host.endsWith("groupl.es") || host.endsWith("sgr-labs.com");
  }

  bool isNoAuth(RequestOptions options) {
    return options.headers.containsKey(_NO_AUTH_HEADER);
  }

  bool isCookieAuth(RequestOptions options) {
    return options.headers.containsKey(_COOKIE_AUTH_HEADER);
  }

  Future<AuthData> refreshToken() async {
    final response = await _tokenRefreshDio.post(
      '${AuthConfig.meweHost}/api/v2/auth/token',
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    final authTokenResponse = AuthTokenResponse.fromJson(response.data);
    return authTokenResponse.getAuthData();
  }
}
