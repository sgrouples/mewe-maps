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
  ContactsBloc(this._contactsRepository, this._sharingLocationRepository, this._hiddenFromMapRepository) : super(const ContactsState(error: "")) {
    on<StartObservingData>(_startObservingData);
    on<ReloadContacts>(_reloadContacts);
    on<ReloadContactLocationData>(_reloadContactLocationData);
    on<ShareMyPositionStarted>(_startSharingPosition);
    on<ShareMyPositionStopped>(_stopSharingPosition);
    on<DisplayOnTheMapChanged>(_displayOnTheMapChanged);
    on<LogOutClicked>(_logOutClicked);
    on<ShareMyPositionChanged>(_shareMyPositionChanged);
    on<ContactLocationDataChanged>(_contactLocationDataChanged);
    on<SearchQueryChanged>(_contactsSearchQueryChanged);
    on<AskForLocationClicked>(_askForLocationClicked);
    on<CancelRequestForLocationClicked>(_cancelRequestForLocationClicked);
  }

  final ContactsRepository _contactsRepository;
  final SharingLocationRepository _sharingLocationRepository;
  final HiddenFromMapRepository _hiddenFromMapRepository;

  StreamSubscription? _contactsLocationsSubscription;
  StreamSubscription? _myPositionSubscription;

  final BehaviorSubject<List<User>> _contactsSubject = BehaviorSubject.seeded([]);
  final BehaviorSubject<String> _contactsSearchQuerySubject = BehaviorSubject.seeded("");

  @override
  void onEvent(ContactsEvent event) {
    super.onEvent(event);
    Logger.log(_TAG, "event ${event.toString()}");
    Logger.log(_TAG, "state ${state.toString()}");
  }

  void _startObservingData(StartObservingData event, Emitter<ContactsState> emit) async {
    try {
      _contactsSubject.value = await _contactsRepository.getContacts();
      emit(state.copyWith(error: ""));
      _observeContactsLocation();
      _observeMySharePositionData();
    } catch (error) {
      emit(state.copyWith(error: "Failed to get contacts. ${error.toString()}"));
    }
  }

  void _reloadContacts(ReloadContacts event, Emitter<ContactsState> emit) async {
    try {
      _contactsSubject.value = [];
      _contactsSubject.value = await _contactsRepository.getContacts(forceRefresh: true);
      emit(state.copyWith(error: ""));
    } catch (error) {
      emit(state.copyWith(error: "Failed to get contacts. ${error.toString()}"));
    }
  }

  void _reloadContactLocationData(ReloadContactLocationData event, Emitter<ContactsState> emit) async {
    emit(state.copyWith(contactLocationData: null));
  }

  void _observeMySharePositionData() {
    _myPositionSubscription = CombineLatestStream.combine3(
        _sharingLocationRepository.observeSharingSessionsAsOwner(StorageRepository.user!.userId).startWith([]),
        _contactsSubject,
        _contactsSearchQuerySubject,
        (sharingSessions, contacts, searchQuery) => (sharingSessions, contacts, searchQuery)).listen((data) {
      _handleMySharingSessions(data.$1, data.$2, data.$3);
    });
  }

  void _handleMySharingSessions(List<SharingSession> sharingSessions, List<User> contacts, String searchQuery) {
    List<MyPositionSharing> myPositions = sharingSessions
        .mapNotNull((session) {
          final contact = contacts.firstOrNullWhere((contact) => contact.userId == session.recipientId);
          if (contact == null) return null;
          return MyPositionSharing(contact: contact, sharingSessionId: session.id, sharedUntil: session.shareUntil);
        })
        .filter((position) => position.contact.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    List<User> filteredContacts = contacts
        .whereNot((contact) => sharingSessions.any((session) => session.recipientId == contact.userId))
        .filter((contact) => contact.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    add(ShareMyPositionChanged(myPositions, filteredContacts));
  }

  void _shareMyPositionChanged(ShareMyPositionChanged event, Emitter<ContactsState> emit) async {
    emit(state.copyWith(
      shareMyPositionData: event.shareMyPositionData,
      contactsToShareWith: event.contactsToShareWith,
    ));
  }

  void _contactLocationDataChanged(ContactLocationDataChanged event, Emitter<ContactsState> emit) async {
    emit(state.copyWith(
      contactLocationData: event.contactLocationData,
      contactsToRequestLocation: event.contactsToRequestLocation,
    ));
  }

  void _contactsSearchQueryChanged(SearchQueryChanged event, Emitter<ContactsState> emit) async {
    _contactsSearchQuerySubject.add(event.query);
    emit(state.copyWith(query: event.query));
  }

  void _askForLocationClicked(AskForLocationClicked event, Emitter<ContactsState> emit) async {
    try {
      await _sharingLocationRepository.requestLocationFromContact(StorageRepository.user!.userId, event.user.userId);
    } catch (error) {
      Logger.log(_TAG, "Failed to ask for location. ${error.toString()}");
    }
  }

  void _cancelRequestForLocationClicked(CancelRequestForLocationClicked event, Emitter<ContactsState> emit) async {
    try {
      await _sharingLocationRepository.cancelRequestForLocation(StorageRepository.user!.userId, event.user.userId);
    } catch (error) {
      Logger.log(_TAG, "Failed to cancel request for location. ${error.toString()}");
    }
  }

  void _observeContactsLocation() {
    _contactsLocationsSubscription = CombineLatestStream.combine5(
        _sharingLocationRepository.observeContactsSharingData(StorageRepository.user!.userId).startWith([]),
        _hiddenFromMapRepository.observeHiddenUsers().startWith([]),
        _contactsSubject,
        _contactsSearchQuerySubject,
        _sharingLocationRepository.observeMyLocationRequests(StorageRepository.user!.userId).startWith([]),
        (contactsSharingData, hiddenUsers, contacts, searchQuery, myLocationRequests) =>
            (contactsSharingData, hiddenUsers, contacts, searchQuery, myLocationRequests)).listen((data) {

      final contactLocationData = data.$1.filter((entry) {
        return entry.contact.name.toLowerCase().contains(data.$4.toLowerCase());
      }).map((sharingData) {
        return MapEntry(sharingData.contact, !data.$2.contains(sharingData.contactId));
      });
      final contactsToRequestLocation = data.$3.filter((contact) {
        return !data.$1.any((sharingData) => sharingData.contactId == contact.userId) && contact.name.toLowerCase().contains(data.$4.toLowerCase());
      }).map((user) {
        return MapEntry(user, data.$5.any((request) => request.requestedUserId == user.userId));
      });

      add(ContactLocationDataChanged(Map.fromEntries(contactLocationData), Map.fromEntries(contactsToRequestLocation)));
    });
  }

  void _startSharingPosition(ShareMyPositionStarted event, Emitter<ContactsState> emit) async {
    try {
      await _sharingLocationRepository.startSharingSession(StorageRepository.user!, event.contact, event.minutes, true);
    } catch (error) {
      Logger.log(_TAG, "Failed to share position. ${error.toString()}");
    }
  }

  void _stopSharingPosition(ShareMyPositionStopped event, Emitter<ContactsState> emit) async {
    try {
      await _sharingLocationRepository.stopSharingSession(event.sessionId);
    } catch (error) {
      Logger.log(_TAG, "Failed to stop sharing position. ${error.toString()}");
    }
  }

  void _displayOnTheMapChanged(DisplayOnTheMapChanged event, Emitter<ContactsState> emit) async {
    try {
      _hiddenFromMapRepository.setUserHidden(event.contact.userId, !event.value);
    } catch (error) {
      Logger.log(_TAG, "Failed to update display on the map. ${error.toString()}");
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
