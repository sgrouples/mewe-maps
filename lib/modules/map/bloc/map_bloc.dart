// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mewe_maps/models/firestore/location_request.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/models/user_position.dart';
import 'package:mewe_maps/repositories/fcm/firebase_cloud_messaging_repository.dart';
import 'package:mewe_maps/repositories/location/my_location_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/map/hidden_from_map_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/services/http/auth_constants.dart';
import 'package:mewe_maps/services/location/location_sharing.dart';
import 'package:mewe_maps/services/location/stop_tracking_on_no_sessions.dart';
import 'package:mewe_maps/services/permissions/permissions.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

part 'map_bloc.g.dart';
part 'map_event.dart';
part 'map_state.dart';

const _TAG = 'MapBloc';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MyLocationRepository _myLocationRepository;
  final SharingLocationRepository _sharingLocationRepository;
  final HiddenFromMapRepository _hiddenFromMapRepository;
  final FirebaseCloudMessagingRepository _firebaseCloudMessagingRepository;

  StreamSubscription? _myPositionSubscription;
  StreamSubscription? _contactsLocationsSubscription;
  StreamSubscription? _locationRequestsSubscription;

  MapBloc(
    this._myLocationRepository,
    this._sharingLocationRepository,
    this._hiddenFromMapRepository,
    this._firebaseCloudMessagingRepository,
  ) : super(const MapState(mapInitialized: false)) {
    on<InitEvent>(_init);
    on<ObserveMyPosition>(
      (event, emit) => _observeMyPosition(),
    );
    on<StopObservingMyPosition>(
      (event, emit) => _stopObservingMyPosition(),
    );
    on<ShowPermissionsRationale>(_showPermissionsRationale);
    on<RequestAllPermissions>(_requestAllPermissions);
    on<UpdateMyPosition>(_updateMyPosition);
    on<UpdateContactsLocation>(_updateContactsPositions);
    on<OpenMeWeClicked>(_openMeWeClicked);
    on<NavigateClicked>(_navigateClicked);
    on<UserClicked>(_userClicked);
    on<UserSelectedFromContacts>(_userSelectedFromContacts);
    on<CloseSelectedUser>(_closeSelectedUser);
    on<PreviousUserClicked>(_previousUserClicked);
    on<NextUserClicked>(_nextUserClicked);
    on<TrackMyPositionClicked>(_trackMyPositionClicked);
    on<TrackSelectedUserClicked>(_trackSelectedUserClicked);
    on<UpdateLocationRequests>(_updateLocationRequests);
    on<RespondForLocationRequest>(_respondForLocationRequest);
  }

  @override
  void onEvent(MapEvent event) {
    super.onEvent(event);
    Logger.log(_TAG, "event ${event.toString()}");
    Logger.log(_TAG, "state ${state.toString()}");
  }

  void _init(InitEvent event, Emitter<MapState> emit) async {
    _observeContactsPosition();
    _observeMyPosition();
    _observeLocationRequests();
    _startObservingFcmToken();
    emit(state.copyWith(mapInitialized: true));
    Logger.sendOnlineLogs();
  }

  void _observeMyPosition() async {
    if (!await areAllPermissionsGranted()) {
      add(ShowPermissionsRationale());
    } else {
      _myPositionSubscription = _myLocationRepository.observePrecisePosition().listen((position) {
        final up = UserPosition(user: StorageRepository.user!, position: position, timestamp: position.timestamp);
        add(UpdateMyPosition(up));
      });
    }
  }

  void _observeLocationRequests() {
    _locationRequestsSubscription = _sharingLocationRepository.observeOtherUsersLocationRequests(StorageRepository.user!.userId).listen((requests) {
      add(UpdateLocationRequests(requests));
    });
  }

  Future<void> _stopObservingMyPosition() async {
    await stopPreciseTrackingOnNoSessions();
    await _myPositionSubscription?.cancel();
  }

  void _observeContactsPosition() {
    _contactsLocationsSubscription = CombineLatestStream.combine2(_sharingLocationRepository.observeContactsSharingData(StorageRepository.user!.userId),
        _hiddenFromMapRepository.observeHiddenUsers(), (contactsSharingData, hiddenUsers) => (contactsSharingData, hiddenUsers)).listen((data) {
      List<UserPosition> contactsLocations = [];

      for (final sharingData in data.$1) {
        if (data.$2.contains(sharingData.contactId) || sharingData.position == null || sharingData.updatedAt == null) {
          continue;
        }
        contactsLocations.add(UserPosition(
          user: sharingData.contact,
          position: sharingData.position!,
          timestamp: sharingData.updatedAt!,
          shareUntil: sharingData.shareUntil,
        ));
      }

      add(UpdateContactsLocation(contactsLocations));
    });
  }

  void _showPermissionsRationale(ShowPermissionsRationale event, Emitter<MapState> emit) async {
    emit(state.copyWith(showPermissionsRationale: true));
  }

  void _requestAllPermissions(RequestAllPermissions event, Emitter<MapState> emit) async {
    if (!await areAllPermissionsGranted()) {
      if (await requestAllPermissions()) {
        _observeMyPosition();
      }
    }
    emit(state.copyWith(showPermissionsRationale: false));
  }

  void _updateMyPosition(UpdateMyPosition event, Emitter<MapState> emit) async {
    emit(state.copyWith(myPosition: event.position));
  }

  void _updateContactsPositions(UpdateContactsLocation event, Emitter<MapState> emit) async {
    if (state.selectedUser != null && state.selectedUser?.user.isMe() == false) {
      final selectedUser = event.positions.firstOrNullWhere((element) => element.user.userId == state.selectedUser!.user.userId);
      emit(state.copyWith(selectedUser: selectedUser));
    }
    emit(state.copyWith(contactsPositions: event.positions));
  }

  void _updateLocationRequests(UpdateLocationRequests event, Emitter<MapState> emit) async {
    final locationRequests = event.locationRequests.map((request) => MapEntry(request, User.fromJson(jsonDecode(request.requestingUserData)))).toList();
    emit(state.copyWith(locationRequests: Map.fromEntries(locationRequests)));
  }

  void _respondForLocationRequest(RespondForLocationRequest event, Emitter<MapState> emit) async {
    if (event.minutesToShare != null) {
      await _sharingLocationRepository.startSharingSession(StorageRepository.user!, event.user, event.minutesToShare!);
      await shareMyLocationWithSessions();
      _sharingLocationRepository.cancelRequestForLocationById(event.request.id!);
    } else {
      _sharingLocationRepository.cancelRequestForLocationById(event.request.id!);
    }
  }

  void _openMeWeClicked(OpenMeWeClicked event, Emitter<MapState> emit) async {
    final url = '${AuthConfig.meweHost}/${event.position.user.handle}';
    final uri = Uri.parse(url);
    await launchUrl(uri);
  }

  void _navigateClicked(NavigateClicked event, Emitter<MapState> emit) async {
    final lat = event.userPosition.position.latitude;
    final lng = event.userPosition.position.longitude;

    if (defaultTargetPlatform == TargetPlatform.android) {
      await launchUrl(Uri.parse('https://maps.google.com/maps?q=$lat,$lng'));
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await launchUrl(Uri.parse('https://maps.apple.com/?q=$lat,$lng'));
    }
  }

  void _closeSelectedUser(CloseSelectedUser event, Emitter<MapState> emit) async {
    emit(state.copyWith(selectedUser: null));
    if (state.trackingState == TrackingState.selectedUser) {
      emit(state.copyWith(trackingState: TrackingState.notTracking));
    }
  }

  void _trackMyPositionClicked(TrackMyPositionClicked event, Emitter<MapState> emit) async {
    if (state.trackingState == TrackingState.myPosition) {
      emit(state.copyWith(trackingState: TrackingState.notTracking));
    } else {
      emit(state.copyWith(trackingState: TrackingState.myPosition));
    }
  }

  void _trackSelectedUserClicked(TrackSelectedUserClicked event, Emitter<MapState> emit) async {
    if (state.trackingState == TrackingState.selectedUser) {
      emit(state.copyWith(trackingState: TrackingState.notTracking));
    } else {
      emit(state.copyWith(trackingState: TrackingState.selectedUser));
    }
  }

  void _userClicked(UserClicked event, Emitter<MapState> emit) async {
    if (state.selectedUser?.user == event.userPosition.user) {
      emit(state.copyWith(selectedUser: null, trackingState: TrackingState.notTracking));
    } else {
      emit(state.copyWith(selectedUser: event.userPosition, trackingState: TrackingState.selectedUser));
    }
  }

  void _userSelectedFromContacts(UserSelectedFromContacts event, Emitter<MapState> emit) async {
    final position = state.contactsPositions.firstOrNullWhere((position) => position.user.userId == event.user.userId) ??
        (event.user == StorageRepository.user ? state.myPosition : null);
    if (position != null) {
      emit(state.copyWith(selectedUser: position, trackingState: TrackingState.selectedUser));
    }
  }

  void _previousUserClicked(PreviousUserClicked event, Emitter<MapState> emit) async {
    _changeUser(emit, -1);
  }

  void _nextUserClicked(NextUserClicked event, Emitter<MapState> emit) async {
    _changeUser(emit, 1);
  }

  void _changeUser(Emitter<MapState> emit, int change) {
    if (state.contactsPositions.length <= 1) return;
    final currentIndex = state.contactsPositions.indexWhere((element) => element.user.userId == state.selectedUser!.user.userId);
    int newIndex = state.selectedUser == null ? 0 : currentIndex + change;
    if (newIndex < 0) newIndex = state.contactsPositions.length - 1;
    if (newIndex > state.contactsPositions.length - 1) newIndex = 0;
    add(UserClicked(state.contactsPositions[newIndex]));
  }

  void _startObservingFcmToken() {
    final userId = StorageRepository.user?.userId;
    if (userId != null) {
      _firebaseCloudMessagingRepository.observeTokenForUser(userId);
    }
  }

  @override
  Future<void> close() async {
    await _stopObservingMyPosition();
    await _contactsLocationsSubscription?.cancel();
    await _firebaseCloudMessagingRepository.close();
    return super.close();
  }
}
