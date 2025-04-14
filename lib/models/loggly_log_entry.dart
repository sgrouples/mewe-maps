// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:json_annotation/json_annotation.dart';

part 'loggly_log_entry.g.dart';

@JsonSerializable()
class LogglyLogEntry {
  @JsonKey(name: "timestamp")
  final String timestamp;
  @JsonKey(name: "level")
  final String level;
  @JsonKey(name: "message")
  final String message;
  @JsonKey(name: "userId")
  final String? userId;
  @JsonKey(name: "tags")
  final List<String> tags;
  @JsonKey(name: "params")
  final Map<String, dynamic>? params;

  const LogglyLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.userId,
    required this.tags,
    this.params,
  });

  factory LogglyLogEntry.fromJson(Map<String, dynamic> json) => _$LogglyLogEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LogglyLogEntryToJson(this);
}
