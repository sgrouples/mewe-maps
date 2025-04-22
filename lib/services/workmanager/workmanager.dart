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

import 'package:mewe_maps/isolates.dart';
import 'package:mewe_maps/services/location/location_sharing.dart';
import 'package:mewe_maps/services/location/stop_tracking_on_no_sessions.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:workmanager/workmanager.dart';

const String _TAG = "workmanagerCallback";
const String _PERIODIC_SHARE_LOCATION_TASK = "_PERIODIC_SHARE_LOCATION_TASK";
const String _PERIODIC_SHARE_LOCATION_TASK_IOS = "com.mewe.maps.periodicLocationTask";
const String _STOP_TRACKING_NO_SESSIONS_TASK = "_STOP_TRACKING_NO_SESSIONS_TASK";

@pragma('vm:entry-point')
void workmanagerCallback() async {
  await initializeIsolate();

  Workmanager().executeTask((task, inputData) async {
    await Logger.saveOnlineLog(_TAG, "executeTask $task");

    if (task == _PERIODIC_SHARE_LOCATION_TASK) {
      await shareMyLocationWithSessions();
    } else if (task == _STOP_TRACKING_NO_SESSIONS_TASK) {
      await stopPreciseTrackingOnNoSessions();
    } else if (task == _PERIODIC_SHARE_LOCATION_TASK_IOS) {
      await shareMyLocationWithSessions(onFinish: registerPeriodicShareTaskOnIOS);
    } else {
      Logger.log(_TAG, "Unknown task: $task");
    }

    return Logger.sendOnlineLogs().then((_) => true);
  });
}

Future<void> initializeWorkManager() async {
  await Workmanager().initialize(workmanagerCallback);
}

Future<void> registerPeriodicShareMyLocationWithSessions() async {
  try {
    if (Platform.isAndroid) {
      await registerPeriodicShareTaskOnAndroid();
    } else if (Platform.isIOS) {
      await registerPeriodicShareTaskOnIOS();
    }
    Logger.log(_TAG, "registerPeriodicShareMyLocationWithSessions success");
  } catch (e) {
    Logger.log(_TAG, "registerPeriodicShareMyLocationWithSessions error: $e");
    return;
  }
}

Future<void> registerPeriodicShareTaskOnIOS() async {
  Logger.log(_TAG, "registerPeriodicShareTaskOnIOS");
  await Workmanager().registerOneOffTask(
    _PERIODIC_SHARE_LOCATION_TASK_IOS,
    _PERIODIC_SHARE_LOCATION_TASK_IOS,
    initialDelay: const Duration(minutes: 20),
  );
}

Future<void> registerPeriodicShareTaskOnAndroid() async {
  await Workmanager().registerPeriodicTask(
    _PERIODIC_SHARE_LOCATION_TASK,
    _PERIODIC_SHARE_LOCATION_TASK,
    frequency: const Duration(minutes: 15),
  );
}

Future<void> registerStopPreciseTrackingOnNoSessions() async {
  await Workmanager().registerOneOffTask(_STOP_TRACKING_NO_SESSIONS_TASK, _STOP_TRACKING_NO_SESSIONS_TASK);
  await Logger.saveOnlineLog(_TAG, "registerStopPreciseTrackingOnNoSessions success");
}
