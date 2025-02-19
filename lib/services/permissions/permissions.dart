import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> areAllPermissionsGranted() async {
  return await Permission.notification.isGranted && await Permission.location.isGranted && await Permission.locationAlways.isGranted;
}

Future<bool> requestAllPermissions() async {
  if (await Permission.notification.isDenied) {
    PermissionStatus permission = await Permission.notification.request();
    if (permission.isDenied) {
      return false;
    }
    if (permission.isPermanentlyDenied) {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
      return false;
    }
  }

  if (await Permission.location.isDenied) {
    PermissionStatus permission = await Permission.location.request();
    if (permission.isDenied) {
      return false;
    }
    if (permission.isPermanentlyDenied) {
      await AppSettings.openAppSettings(type: AppSettingsType.location);
      return false;
    }
  }

  if (await Permission.locationAlways.isDenied) {
    PermissionStatus permission = await Permission.locationAlways.request();
    if (permission.isDenied) {
      return false;
    }
    if (permission.isPermanentlyDenied) {
      await AppSettings.openAppSettings(type: AppSettingsType.location);
      return false;
    }
  }

  return true;
}
