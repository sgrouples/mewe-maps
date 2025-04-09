// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/services/http/loggly_service.dart';
import 'package:mewe_maps/utils/logger.dart';

const _TAG = "LogglyLogger";

void initializeLogglyLogger() {
  LogglyLogger.instance.configure(token: dotenv.env["LOGGLY_TOKEN"], baseUrl: "http://logs-01.loggly.com/");
}

class LogglyLogger {
  static final LogglyLogger instance = LogglyLogger._internal();

  LogglyService? _logglyService;
  String? _token;

  LogglyLogger._internal();

  void configure({required String? token, required String baseUrl, String? tag}) {
    _token = token;
    final dio = Dio();
    _logglyService = LogglyService(dio, baseUrl: baseUrl);
  }

  void log(String message, {String? tag, String level = 'info', Map<String, dynamic>? params}) {
    final Map<String, dynamic> payload = {
      'level': level,
      'message': message,
      'userId': StorageRepository.user?.userId,
      'params': params ?? {},
    };

    final tags = createTags(tag).join(',');

    _logglyService?.sendLog(_token!, tags, payload).then((_) {
      Logger.log(_TAG, 'Loggly log sent: $message');
    }).catchError((error) {
      Logger.log(_TAG, 'Loggly error: $error');
    });
  }

  List<String> createTags(String? tag) {
    List<String> tags = [];
    if (tag != null) {
      tags.add(tag);
    }
    if (Platform.isIOS) {
      tags.add("ios");
    } else if (Platform.isAndroid) {
      tags.add("android");
    }
    if (kDebugMode) {
      tags.add("debug");
    } else {
      tags.add("release");
    }
    return tags;
  }
}
