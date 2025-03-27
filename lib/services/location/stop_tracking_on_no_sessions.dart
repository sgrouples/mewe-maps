// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:mewe_maps/models/firestore/sharing_session.dart';
import 'package:mewe_maps/repositories/location/my_location_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/utils/logger.dart';

const String _TAG = "stopPreciseTrackingOnNoSessions";

Future<void> stopPreciseTrackingOnNoSessions() async {
  Logger.log(_TAG, "called");

  final myLocationRepository = MyLocationRepositoryImpl();

  if (!await myLocationRepository.isObservingPrecisePosition()) {
    Logger.log(_TAG, "not observing precise position");
    return;
  }

  final userId = StorageRepository.user?.userId;
  List<SharingSession>? sessions;

  if (userId != null) {
    sessions = await FirestoreSharingLocationRepository().getSharingSessionsAsOwner(userId);
    Logger.log(_TAG, "sessions=${sessions?.length}");
  }

  if (sessions == null || sessions.isEmpty) {
    Logger.log(_TAG, "cancelling");
    await myLocationRepository.cancelObservingPrecisePosition();
  }
}
