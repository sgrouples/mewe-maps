import 'dart:convert';

import 'package:mewe_maps/models/auth_data.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageRepository {
  static late SharedPreferences _prefs;

  static initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _kAuthData = "AuthData";
  static const _kUser = "User";

  static bool getFlag(String key, bool def) {
    final value = _prefs.getBool(key);
    if (value == null) return def;
    return value;
  }

  static setFlag(String key, bool value) {
    _prefs.setBool(key, value);
  }

  static AuthData? get authData {
    final string = _prefs.getString(_kAuthData);
    if (string == null) return null;
    final map = jsonDecode(string);
    return AuthData.fromJson(map);
  }

  static setAuthData(AuthData authData) {
    final string = jsonEncode(authData);
    _prefs.setString(_kAuthData, string);
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

  static clear() {
    _prefs.clear();
  }
}
