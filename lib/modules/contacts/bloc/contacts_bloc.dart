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

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mewe_maps/main.dart';
import 'package:mewe_maps/models/firestore/sharing_session.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/repositories/contacts/contacts_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/map/hidden_from_map_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:rxdart/rxdart.dart';

part 'contacts_bloc.g.dart';
part 'contacts_event.dart';
part 'contacts_state.dart';

const _TAG = 'ContactsBloc';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc(this._contactsRepository, this._sharingLocationRepository,
      this._hiddenFromMapRepository)
      : super(const ContactsState(error: "")) {
    on<StartObservingData>(_loadContacts);
    on<ShareMyPositionStarted>(_startSharingPosition);
    on<ShareMyPositionStopped>(_stopSharingPosition);
    on<DisplayOnTheMapChanged>(_displayOnTheMapChanged);
    on<LogOutClicked>(_logOutClicked);
    on<ShareMyPositionChanged>(_shareMyPositionChanged);
    on<ContactLocationDataChanged>(_contactLocationDataChanged);
  }

  final ContactsRepository _contactsRepository;
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
    _sharingLocationRepository
        .getSharingSessionsAsOwner(StorageRepository.user!.userId)
        .then((sharingSessions) {
      if (sharingSessions == null) return;
      _handleMySharingSessions(sharingSessions);
    });
  }

  void _handleMySharingSessions(List<SharingSession> sharingSessions) {
    List<MyPositionSharing> myPositions = sharingSessions.mapNotNull((session) {
      final contact = _contacts
          .firstOrNullWhere((contact) => contact.userId == session.recipientId);
      if (contact == null) return null;
      return MyPositionSharing(
          contact: contact,
          sharingSessionId: session.id,
          sharedUntil: session.shareUntil);
    }).toList();

    List<User> filteredContacts = _contacts
        .whereNot((contact) => sharingSessions
            .any((session) => session.recipientId == contact.userId))
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
          sharingData.contact,
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
