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

@CopyWith()
class ContactsState extends Equatable {
  const ContactsState({
    this.shareMyPositionData,
    this.contactsToShareWith,
    this.contactLocationData,
    this.contactsToRequestLocation,
    this.query = "",
    required this.error,
  });

  final List<MyPositionSharing>? shareMyPositionData;
  final List<User>? contactsToShareWith;
  final Map<User, bool>? contactLocationData;
  final Map<User, bool>? contactsToRequestLocation;
  final String error;
  final String query;

  @override
  List<Object?> get props => [shareMyPositionData, contactsToShareWith, contactLocationData, error, contactsToRequestLocation, query];
}

@CopyWith()
class MyPositionSharing extends Equatable {
  final User contact;
  final String sharingSessionId;
  final DateTime sharedUntil;

  const MyPositionSharing({required this.contact, required this.sharingSessionId, required this.sharedUntil});

  @override
  List<Object?> get props => [contact, sharingSessionId, sharedUntil];
}
