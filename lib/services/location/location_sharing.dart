// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:mewe_maps/repositories/location/my_location_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/utils/logger.dart';

const String _TAG = "shareMyLocationWithSessions";

Future<bool> shareMyLocationWithSessions() async {
  await Logger.logToLogglyCache(_TAG, "shareMyLocationWithSessions");

  final userId = StorageRepository.user?.userId;
  if (userId != null) {
    final lastPosition = await MyLocationRepositoryImpl().getLastKnownPosition();

    if (lastPosition != null) {
      final sharingRepository = FirestoreSharingLocationRepository();
      final sessions = await sharingRepository.getSharingSessionsAsOwner(userId);
      if (sessions != null && sessions.isNotEmpty) {
        await sharingRepository.uploadPosition(lastPosition, sessions);
        await Logger.logToLogglyCache(_TAG, "success");
        return true;
      } else {
        await Logger.logToLogglyCache(_TAG, "failed (no sessions)");
      }
    } else {
      await Logger.logToLogglyCache(_TAG, "failed (no last position)");
    }
  } else {
    await Logger.logToLogglyCache(_TAG, "failed (no current user)");
  }
  return false;
}
