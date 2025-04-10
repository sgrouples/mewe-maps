// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {}

class StartObservingData extends ContactsEvent {
  @override
  List<Object?> get props => ['StartObservingData'];
}

class ShareMyPositionStarted extends ContactsEvent {
  final User contact;
  final int minutes;

  ShareMyPositionStarted(this.contact, this.minutes);

  @override
  List<Object?> get props => [contact, minutes];
}

class ShareMyPositionStopped extends ContactsEvent {
  final String sessionId;

  ShareMyPositionStopped(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class ShareMyPositionChanged extends ContactsEvent {
  final List<MyPositionSharing>? shareMyPositionData;
  final List<User>? contactsToShareWith;

  ShareMyPositionChanged(this.shareMyPositionData, this.contactsToShareWith);

  @override
  List<Object?> get props => [shareMyPositionData, contactsToShareWith];
}

class ContactLocationDataChanged extends ContactsEvent {
  final Map<User, bool>? contactLocationData;
  final Map<User, bool> contactsToRequestLocation;

  ContactLocationDataChanged(this.contactLocationData, this.contactsToRequestLocation);

  @override
  List<Object?> get props => [contactLocationData, contactsToRequestLocation];
}

class DisplayOnTheMapChanged extends ContactsEvent {
  final User contact;
  final bool value;

  DisplayOnTheMapChanged(this.contact, this.value);

  @override
  List<Object?> get props => [contact, value];
}

class LogOutClicked extends ContactsEvent {
  final BuildContext context;

  LogOutClicked(this.context);

  @override
  List<Object?> get props => [context];
}

class ReloadContacts extends ContactsEvent {
  @override
  List<Object?> get props => ['ReloadContacts'];
}

class ReloadContactLocationData extends ContactsEvent {
  @override
  List<Object?> get props => ['ReloadContactLocationData'];
}

class SearchQueryChanged extends ContactsEvent {
  final String query;

  SearchQueryChanged(this.query);

  @override
  List<Object?> get props => ['ContactsSearchQueryChanged'];
}

class AskForLocationClicked extends ContactsEvent {
  final User user;

  AskForLocationClicked(this.user);

  @override
  List<Object?> get props => [user];
}

class CancelRequestForLocationClicked extends ContactsEvent {
  final User user;

  CancelRequestForLocationClicked(this.user);

  @override
  List<Object?> get props => [user];
}
