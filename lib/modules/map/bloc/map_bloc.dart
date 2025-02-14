import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/models/user_position.dart';
import 'package:mewe_maps/repositories/location/my_location_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/map/hidden_from_map_repository.dart';
import 'package:mewe_maps/repositories/map/map_controller_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/services/http/auth_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

part 'map_bloc.g.dart';
part 'map_event.dart';
part 'map_state.dart';

const _TAG = 'MapBloc';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MyLocationRepository _myLocationRepository;
  final SharingLocationRepository _sharingLocationRepository;
  final MapControllerRepository _mapControllerRepository;
  final HiddenFromMapRepository _hiddenFromMapRepository;

  late StreamSubscription _myPositionSubscription;
  late StreamSubscription _contactsLocationsSubscription;

  MapBloc(this._myLocationRepository, this._sharingLocationRepository,
      this._mapControllerRepository, this._hiddenFromMapRepository)
      : super(const MapState(mapInitialized: false)) {
    on<InitEvent>(_init);
    on<ObserveMyPosition>(
      (event, emit) => _observeMyPosition(),
    );
    on<StopObservingMyPosition>(
      (event, emit) => _stopObservingMyPosition(),
    );
    on<UpdateMyPosition>(_updateMyPosition);
    on<UpdateContactsLocation>(_updateContactsPositions);
    on<OpenMeWeClicked>(_openMeWeClicked);
    on<NavigateClicked>(_navigateClicked);
    on<GeopointClicked>(_geopointClicked);
    on<CloseSelectedUser>(_closeSelectedUser);
    on<PreviousUserClicked>(_previousUserClicked);
    on<NextUserClicked>(_nextUserClicked);
  }

  void _init(InitEvent event, Emitter<MapState> emit) async {
    _observeContactsPosition();
    _observeMapSingleTap();
    _observeMyPosition();
    emit(state.copyWith(mapInitialized: true));
  }

  void _observeMapSingleTap() {
    _mapControllerRepository.mapController.listenerMapSingleTapping
        .addListener(() {
      final geoPoint =
          _mapControllerRepository.mapController.listenerMapSingleTapping.value;
      if (geoPoint != null) {
        add(CloseSelectedUser());
      }
    });
  }

  void _observeMyPosition() async {
    _myPositionSubscription =
        _myLocationRepository.observePrecisePosition().listen((position) {
      final up = UserPosition(
          user: StorageRepository.user!,
          position: position,
          timestamp: position.timestamp);
      add(UpdateMyPosition(up));
    });
  }

  void _stopObservingMyPosition() async {
    _myPositionSubscription.cancel();
    final sessions = await _sharingLocationRepository
        .getSharingSessionsAsOwner(StorageRepository.user!.userId);
    final hasPreciseSharing =
        sessions?.any((session) => session.isPrecise) ?? false;
    if (!hasPreciseSharing) {
      await _myLocationRepository.cancelObservingPrecisePosition();
    }
  }

  void _observeContactsPosition() {
    _contactsLocationsSubscription = CombineLatestStream.combine2(
        _sharingLocationRepository
            .observeContactsSharingData(StorageRepository.user!.userId),
        _hiddenFromMapRepository.observeHiddenUsers(),
        (contactsSharingData, hiddenUsers) =>
            (contactsSharingData, hiddenUsers)).listen((data) {
      List<UserPosition> contactsLocations = [];

      for (final sharingData in data.$1) {
        if (data.$2.contains(sharingData.contactId)) {
          continue;
        }
        contactsLocations.add(UserPosition(
          user: User.fromJson(jsonDecode(sharingData.userDataRaw)),
          position:
              Position.fromMap(jsonDecode(sharingData.data.positionDataRaw)),
          timestamp: sharingData.data.updatedAt,
          shareUntil: sharingData.shareUntil,
        ));
      }

      add(UpdateContactsLocation(contactsLocations));
    });
  }

  void _updateMyPosition(UpdateMyPosition event, Emitter<MapState> emit) async {
    UserPosition? currentPosition = _mapControllerRepository.myPosition;
    UserPosition? newPosition = event.position;
    if (currentPosition == null && newPosition == null) {
      return;
    }
    if (state.selectedUser != null && state.selectedUser == currentPosition) {
      emit(state.copyWith(selectedUser: newPosition));
    }
    _mapControllerRepository.displayMyPosition(newPosition);
  }

  void _updateContactsPositions(
      UpdateContactsLocation event, Emitter<MapState> emit) async {
    List<UserPosition>? currentPositions =
        _mapControllerRepository.contactsPositions;
    List<UserPosition> newPositions = event.positions;
    if (currentPositions.isEmpty && newPositions.isEmpty) {
      return;
    }
    if (state.selectedUser != null) {
      final selectedUser = newPositions.firstOrNullWhere(
          (element) => element.user.userId == state.selectedUser!.user.userId);
      if (selectedUser != null) {
        emit(state.copyWith(selectedUser: selectedUser));
      }
    }
    _mapControllerRepository.displayContactsPositions(newPositions);
  }

  void _openMeWeClicked(OpenMeWeClicked event, Emitter<MapState> emit) async {
    final url = '${AuthConfig.meweHost}/${event.position.user.publicLinkId}';
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

  void _closeSelectedUser(
      CloseSelectedUser event, Emitter<MapState> emit) async {
    emit(state.copyWith(selectedUser: null));
  }

  void _geopointClicked(GeopointClicked event, Emitter<MapState> emit) async {
    final userPosition =
        _mapControllerRepository.findUserPosition(event.geoPoint);
    if (state.selectedUser == userPosition) {
      emit(state.copyWith(selectedUser: null));
    } else {
      emit(state.copyWith(selectedUser: userPosition));
    }
    if (state.selectedUser != null) {
      _mapControllerRepository.moveToPosition(state.selectedUser!);
    }
  }

  void _previousUserClicked(
      PreviousUserClicked event, Emitter<MapState> emit) async {
    _changeUser(emit, -1);
  }

  void _nextUserClicked(NextUserClicked event, Emitter<MapState> emit) async {
    _changeUser(emit, 1);
  }

  void _changeUser(Emitter<MapState> emit, int change) {
    final allUsers = [
      ..._mapControllerRepository.contactsPositions,
      _mapControllerRepository.myPosition
    ].whereNotNull().toList();
    if (allUsers.length <= 1) return;
    final currentIndex = allUsers.indexWhere((element) =>
    element.user.userId == state.selectedUser!.user.userId);
    int newIndex = state.selectedUser == null ? 0 : currentIndex + change;
    if (newIndex < 0) newIndex = allUsers.length - 1;
    if (newIndex > allUsers.length - 1) newIndex = 0;
    add(GeopointClicked(allUsers[newIndex].geoPoint));
  }

  @override
  Future<void> close() async {
    _contactsLocationsSubscription.cancel();
    _stopObservingMyPosition();
    return super.close();
  }
}
