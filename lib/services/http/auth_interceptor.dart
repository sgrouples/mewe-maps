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
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/services/http/auth_constants.dart';
import 'package:mewe_maps/services/http/dio_client.dart';
import 'package:mewe_maps/services/http/model/get_token_response.dart';
import 'package:mewe_maps/utils/logger.dart';

const String _TAG = "AuthInterceptor";

class AuthInterceptor extends Interceptor {
  static const String _APP_ID = 'X-App-Id';
  static const String _API_KEY = 'X-Api-Key';
  static const String _AUTH_KEY = 'Authorization';
  static const String _COOKIE_AUTH_HEADER = '@CookieAuth';
  static const String _NO_AUTH_HEADER = '@NoAuth';

  final Dio _tokenRefreshDio = DioClient.createDio();
  Completer? _tokenRefreshCompleter;

  AuthInterceptor() {
    _tokenRefreshDio.interceptors.insert(0, this);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isMeweRequest(options.uri.host) || _isCookieAuth(options) || _isNoAuth(options)) {
      Logger.log(_TAG, "CookieAuth or NoAuth request: ${options.uri}");
      options.headers.remove(_COOKIE_AUTH_HEADER);
      options.headers.remove(_NO_AUTH_HEADER);
      return handler.next(options);
    }

    if (!options.headers.containsKey(Headers.contentTypeHeader)) {
      options.headers[Headers.contentTypeHeader] = Headers.jsonContentType;
    }

    if (options.uri.path.endsWith('/api/dev/signin') || options.uri.path.endsWith('/api/dev/token')) {
      Logger.log(_TAG, "Authentication request: ${options.uri}");
      options.headers[_APP_ID] = AuthConfig.meweAppId;
      options.headers[_API_KEY] = AuthConfig.meweApiKey;
      return handler.next(options);
    }

    if (_tokenRefreshCompleter != null) {
      Logger.log(_TAG, "Waiting for token refresh: ${options.uri}");
      await _tokenRefreshCompleter?.future;
      _tokenRefreshCompleter = null;
      return onRequest(options, handler);
    }

    String token = StorageRepository.token!;
    options.headers[_APP_ID] = AuthConfig.meweAppId;
    options.headers[_AUTH_KEY] = 'Bearer $token';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _tokenRefreshCompleter = Completer<void>();
      try {
        final newToken = await refreshToken();
        if (newToken != null) {
          StorageRepository.setToken(newToken);
          _tokenRefreshCompleter?.complete();
          final retryOptions = err.requestOptions;
          retryOptions.headers[_APP_ID] = AuthConfig.meweAppId;
          retryOptions.headers[_AUTH_KEY] = 'Bearer $newToken';
          final response = await _tokenRefreshDio.fetch(retryOptions);
          return handler.resolve(response);
        } else {
          return handler.next(err);
        }
      } catch (e) {
        _tokenRefreshCompleter?.completeError(e);
        return handler.next(err);
      } finally {
        _tokenRefreshCompleter = null;
      }
    }

    return handler.next(err);
  }

  bool _isMeweRequest(String host) {
    return AuthConfig.meweHost.contains(host);
  }

  bool _isNoAuth(RequestOptions options) {
    return options.headers.containsKey(_NO_AUTH_HEADER);
  }

  bool _isCookieAuth(RequestOptions options) {
    return options.headers.containsKey(_COOKIE_AUTH_HEADER);
  }

  Future<String?> refreshToken() async {
    final response = await _tokenRefreshDio.post(
      '${AuthConfig.meweHost}/api/dev/token',
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
    final tokenResponse = GetTokenResponse.fromJson(response.data);
    if (tokenResponse.pending) {
      return null;
    } else {
      return tokenResponse.token;
    }
  }
}
