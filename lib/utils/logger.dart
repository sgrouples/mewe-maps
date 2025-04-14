// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:flutter/foundation.dart';

import 'loggly_logger.dart';

class Logger {
  static bool LOG_DIO = true;

  static void log(String tag, String text) {
    if (kDebugMode) {
      final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
      pattern.allMatches(text).forEach((match) => print("MEWE_MAPS: $tag: ${match.group(0)}"));
    }
  }

  static Future<void> saveOnlineLog(String tag, String text, {Map<String, dynamic>? params}) async {
    try {
      await LogglyLogger.instance.log(text, tag: tag, params: params);
    } catch (e) {
      log(tag, "LogglyLogger error: $e");
    }
    log(tag, text);
  }

  static Future<void> sendOnlineLogs() async {
    try {
      await LogglyLogger.instance.sendPendingLogs();
    } catch (e) {
      log("Logger", "Error sending logs to Loggly: $e");
    }
  }
}
