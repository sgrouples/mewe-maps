// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:flutter/widgets.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _TAG = "AppLifecycleTracker";
const _KEY = "isAppVisible";

typedef AppVisibilityCallback = void Function(bool isAppVisible);

class AppLifecycleTracker with WidgetsBindingObserver {
  static final SharedPreferencesAsync _preferencesAsync = SharedPreferencesAsync();
  static final Set<AppVisibilityCallback> _callbacks = {};

  static Future<bool> isAppVisible() async {
    return await _preferencesAsync.getBool(_KEY) == true;
  }

  static void addVisibilityCallback(AppVisibilityCallback callback) {
    _callbacks.add(callback);
  }

  static void removeVisibilityCallback(AppVisibilityCallback callback) {
    _callbacks.remove(callback);
  }

  void initObserver() async {
    WidgetsBinding.instance.addObserver(this);
    await _preferencesAsync.setBool(_KEY, true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    bool isAppResumed = (state == AppLifecycleState.resumed);
    bool previousState = await isAppVisible();

    if (isAppResumed != previousState) {
      Logger.log(_TAG, "didChangeAppLifecycleState isAppResumed=$isAppResumed");
      await _preferencesAsync.setBool(_KEY, isAppResumed);

      for (var callback in _callbacks) {
        callback(isAppResumed);
      }
    }
  }
}
