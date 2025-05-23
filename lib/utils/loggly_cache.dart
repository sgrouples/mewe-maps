// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'dart:convert';
import 'dart:io';
import 'package:mewe_maps/models/loggly_log_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class LogglyCache {
  static const _fileName = 'loggly_cache.jsonl';
  File? _logFile;
  final Lock _lock = Lock();

  Future<File> _getLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/$_fileName');
    return _logFile!;
  }

  Future<void> cacheLog(LogglyLogEntry log) async {
    await _lock.synchronized(() async {
      final file = _logFile ?? await _getLogFile();
      final logLine = '${jsonEncode(log.toJson())}\n';
      await file.writeAsString(logLine, mode: FileMode.append, flush: true);
    });
  }

  Future<List<String>> readCachedLogs() async {
    return await _lock.synchronized(() async {
      final file = await _getLogFile();
      if (!await file.exists()) return [];

      final lines = await file.readAsLines();
      return lines.toList();
    });
  }

  Future<void> clearCache() async {
    await _lock.synchronized(() async {
      final file = _logFile ?? await _getLogFile();
      if (await file.exists()) {
        await file.delete();
      }
    });
  }
}
