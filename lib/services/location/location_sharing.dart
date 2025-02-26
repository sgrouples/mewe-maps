// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:dartx/dartx_io.dart';
import 'package:mewe_maps/repositories/location/my_location_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/utils/logger.dart';

const String _TAG = "shareMyLocationWithSessions";

Future<bool> shareMyLocationWithSessions(bool isPrecise) async {
  Logger.log(_TAG, "called with isPrecise=$isPrecise");

  final userId = StorageRepository.user?.userId;
  if (userId != null) {
    final lastPosition = await MyLocationRepositoryImpl().getLastKnownPosition();

    if (lastPosition != null) {
      final sharingRepository = SupabaseSharingLocationRepository();
      final sessions = await sharingRepository.getSharingSessionsAsOwner(userId);
      if (sessions != null && sessions.isNotEmpty) {
        final filteredSessions = sessions.filter((session) => session.isPrecise == isPrecise).toList();
        await sharingRepository.uploadPosition(lastPosition, filteredSessions);
        Logger.log(_TAG, "success");
        return true;
      } else {
        Logger.log(_TAG, "failed (no sessions)");
      }
    } else {
      Logger.log(_TAG, "failed (no last position)");
    }
  } else {
    Logger.log(_TAG, "failed (no current user)");
  }
  return false;
}
