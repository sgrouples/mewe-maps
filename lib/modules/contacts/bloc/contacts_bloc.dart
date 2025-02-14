import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mewe_maps/main.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/models/user_position.dart';
import 'package:mewe_maps/models/user_sharing_session.dart';
import 'package:mewe_maps/repositories/contacts/contacts_repository.dart';
import 'package:mewe_maps/repositories/map/hidden_from_map_repository.dart';
import 'package:mewe_maps/repositories/map/map_controller_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/services/http/auth_constants.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

part 'contacts_bloc.g.dart';
part 'contacts_event.dart';
part 'contacts_state.dart';

const _TAG = 'ContactsBloc';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc(this._contactsRepository, this._mapControllerRepository,
      this._sharingLocationRepository, this._hiddenFromMapRepository)
      : super(const ContactsState(error: "")) {
    on<StartObservingData>(_loadContacts);
    on<ShareMyPositionStarted>(_startSharingPosition);
    on<ShareMyPositionStopped>(_stopSharingPosition);
    on<DisplayOnTheMapChanged>(_displayOnTheMapChanged);
    on<ContactClicked>(_contactClicked);
    on<LogOutClicked>(_logOutClicked);
    on<ShareMyPositionChanged>(_shareMyPositionChanged);
    on<ContactLocationDataChanged>(_contactLocationDataChanged);
  }

  final ContactsRepository _contactsRepository;
  final MapControllerRepository _mapControllerRepository;
  final SharingLocationRepository _sharingLocationRepository;
  final HiddenFromMapRepository _hiddenFromMapRepository;

  StreamSubscription? _contactsLocationsSubscription;
  StreamSubscription? _myPositionSubscription;

  List<User> _contacts = [];

  void _loadContacts(
      StartObservingData event, Emitter<ContactsState> emit) async {
    try {
      _contacts = await _contactsRepository.getContacts();
      emit(state.copyWith(error: ""));
      _observeContactsLocation();
      _observeMySharePositionData();
    } catch (error) {
      emit(
          state.copyWith(error: "Failed to get contacts. ${error.toString()}"));
    }
  }

  void _observeMySharePositionData() {
    _myPositionSubscription = _sharingLocationRepository
        .observeSharingSessionsAsOwner(StorageRepository.user!.userId)
        .startWith([]).listen((sharingSessions) {

      _handleMySharingSessions(sharingSessions);
    });
  }

  void _refreshSharingSessions() {
    _sharingLocationRepository.getSharingSessionsAsOwner(StorageRepository.user!.userId).then((sharingSessions) {
      if (sharingSessions == null) return;
      _handleMySharingSessions(sharingSessions);
    });
  }

  void _handleMySharingSessions(List<UserSharingSession> sharingSessions) {
    List<MyPositionSharing> myPositions =
        sharingSessions.mapNotNull((session) {
      final contact = _contacts.firstOrNullWhere(
          (contact) => contact.userId == session.recipientId);
      if (contact == null) return null;
      return MyPositionSharing(
          contact: contact,
          sharingSessionId: session.id,
          sharedUntil: session.shareUntil);
    }).toList();

    List<User> filteredContacts = _contacts
        .whereNot((contact) =>
            sharingSessions.any((session) => session.recipientId == contact.userId))
        .toList();
    add(ShareMyPositionChanged(myPositions, filteredContacts));
  }

  void _shareMyPositionChanged(
      ShareMyPositionChanged event, Emitter<ContactsState> emit) async {
    emit(state.copyWith(
      shareMyPositionData: event.shareMyPositionData,
      contacts: event.contacts,
    ));
  }

  void _contactLocationDataChanged(
      ContactLocationDataChanged event, Emitter<ContactsState> emit) async {
    emit(state.copyWith(
      contactLocationData: event.contactLocationData,
    ));
  }

  void _observeContactsLocation() {
    _contactsLocationsSubscription = CombineLatestStream.combine2(
        _sharingLocationRepository
            .observeContactsSharingData(StorageRepository.user!.userId)
            .startWith([]),
        _hiddenFromMapRepository.observeHiddenUsers().startWith([]),
        (contactsSharingData, hiddenUsers) =>
            (contactsSharingData, hiddenUsers)).listen((data) {
      final contactLocationData = data.$1.map((sharingData) {
        return MapEntry(
          User.fromJson(jsonDecode(sharingData.userDataRaw)),
          !data.$2.contains(sharingData.contactId),
        );
      });
      add(ContactLocationDataChanged(Map.fromEntries(contactLocationData)));
    });
  }

  void _startSharingPosition(
      ShareMyPositionStarted event, Emitter<ContactsState> emit) async {
    try {
      await _sharingLocationRepository.startSharingSession(
          StorageRepository.user!, event.contact, event.minutes, true);
      _refreshSharingSessions();
    } catch (error) {
      Logger.log(_TAG, "Failed to share position. ${error.toString()}");
    }
  }

  void _stopSharingPosition(
      ShareMyPositionStopped event, Emitter<ContactsState> emit) async {
    try {
      await _sharingLocationRepository.stopSharingSession(event.sessionId);
      _refreshSharingSessions();
    } catch (error) {
      Logger.log(_TAG, "Failed to stop sharing position. ${error.toString()}");
    }
  }

  void _displayOnTheMapChanged(
      DisplayOnTheMapChanged event, Emitter<ContactsState> emit) async {
    try {
      _hiddenFromMapRepository.setUserHidden(
          event.contact.userId, !event.value);
    } catch (error) {
      Logger.log(
          _TAG, "Failed to update display on the map. ${error.toString()}");
    }
  }

  void _contactClicked(
      ContactClicked event, Emitter<ContactsState> emit) async {
    UserPosition? userPosition =
        _mapControllerRepository.findUserPositionByUserId(event.contact.userId);
    if (userPosition != null) {
      _mapControllerRepository.moveToPosition(userPosition);
      Navigator.of(event.context).pop();
    } else {
      final url = '${AuthConfig.meweHost}/${event.contact.publicLinkId}';
      final uri = Uri.parse(url);
      await launchUrl(uri);
    }
  }

  void _logOutClicked(LogOutClicked event, Emitter<ContactsState> emit) async {
    StorageRepository.clear();
    RestartWidget.restartApp(event.context);
  }

  @override
  Future<void> close() async {
    _contactsLocationsSubscription?.cancel();
    _myPositionSubscription?.cancel();
    return super.close();
  }
}
