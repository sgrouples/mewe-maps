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
import 'package:retrofit/retrofit.dart';

part 'loggly_service.g.dart';

@RestApi()
abstract class LogglyService {
  factory LogglyService(Dio dio, {String baseUrl}) = _LogglyService;

  /// Send logs in bulk to Loggly
  /// Logs in jsonl format
  @POST("bulk/{token}/tag/batch/")
  Future<void> sendLogsInBulk(@Path("token") String token, @Body() String logData);
}
