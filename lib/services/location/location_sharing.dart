
import 'package:dartx/dartx_io.dart';
import 'package:mewe_maps/repositories/location/my_location_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
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
