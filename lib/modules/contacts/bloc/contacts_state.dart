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
  const ContactsState(
      {this.shareMyPositionData,
      this.contacts,
      this.contactLocationData,
      required this.error,
      this.contactsSearchQuery = "",
      this.contactLocationDataSearchQuery = ""});

  final List<MyPositionSharing>? shareMyPositionData;
  final List<User>? contacts;
  final Map<User, bool>? contactLocationData;
  final String error;
  final String contactsSearchQuery;
  final String contactLocationDataSearchQuery;

  @override
  List<Object?> get props => [shareMyPositionData, contacts, contactLocationData, error, contactsSearchQuery, contactLocationDataSearchQuery];
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
