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
