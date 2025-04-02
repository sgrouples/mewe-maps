// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:dio/dio.dart';
import 'package:mewe_maps/services/http/timeout_constants.dart';
import 'package:mewe_maps/utils/logger.dart';

class DioClient {
  static Dio createDio() {
    Dio dio = Dio(BaseOptions(
      connectTimeout: Timeouts.connectTimeout,
      sendTimeout: Timeouts.sendTimeout,
      receiveTimeout: Timeouts.receiveTimeout,
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) {
        if (Logger.LOG_DIO) {
          Logger.log("LogInterceptor", o.toString());
        }
      },
    ));

    return dio;
  }
}
