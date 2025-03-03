// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:mewe_maps/isolates.dart';
import 'package:mewe_maps/services/location/location_sharing.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:workmanager/workmanager.dart';

const String _TAG = "workmanagerCallback";
const String _NOT_PRECISE_BACKGROUND_SHARING_TASK = "NotPreciseBackgroundSharing";

@pragma('vm:entry-point')
void workmanagerCallback() async {
  await initializeIsolate();

  Workmanager().executeTask((task, inputData) async {
    Logger.log(_TAG, "executeTask $task");

    if (task == _NOT_PRECISE_BACKGROUND_SHARING_TASK) {
      await shareMyLocationWithSessions(false);
    }

    return Future.value(true);
  });
}

Future<void> initializeNotPreciseBackgroundSharing() async {
  Workmanager().initialize(workmanagerCallback);
  Workmanager().registerPeriodicTask(
    _NOT_PRECISE_BACKGROUND_SHARING_TASK,
    _NOT_PRECISE_BACKGROUND_SHARING_TASK,
    frequency: const Duration(minutes: 15),
  );
}
