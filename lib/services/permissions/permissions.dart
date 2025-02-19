// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> areAllPermissionsGranted() async {
  return await Permission.notification.isGranted &&
      await Permission.location.isGranted &&
      await Permission.locationAlways.isGranted;
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
