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

import 'package:mewe_maps/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageRepository {
  static late SharedPreferences _prefs;

  static initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _kLoginToken = "LoginToken";
  static const _kToken = "Token";
  static const _kUser = "User";

  static bool getFlag(String key, bool def) {
    final value = _prefs.getBool(key);
    if (value == null) return def;
    return value;
  }

  static setFlag(String key, bool value) {
    _prefs.setBool(key, value);
  }

  static User? get user {
    final string = _prefs.getString(_kUser);
    if (string == null) return null;
    final map = jsonDecode(string);
    return User.fromJson(map);
  }

  static setUser(User user) {
    final string = jsonEncode(user);
    _prefs.setString(_kUser, string);
  }

  static String? get loginToken {
    return _prefs.getString(_kLoginToken);
  }

  static setLoginToken(String loginToken) {
    _prefs.setString(_kLoginToken, loginToken);
  }

  static String? get token {
    return _prefs.getString(_kToken);
  }

  static setToken(String token) {
    _prefs.setString(_kToken, token);
  }

  static clear() {
    _prefs.clear();
  }
}
