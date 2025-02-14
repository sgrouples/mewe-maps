part of 'contacts_bloc.dart';

@CopyWith()
class ContactsState extends Equatable {
  const ContactsState({this.shareMyPositionData, this.contacts, this.contactLocationData, required this.error});

  final List<MyPositionSharing>? shareMyPositionData;
  final List<User>? contacts;
  final Map<User, bool>? contactLocationData;
  final String error;

  @override
  List<Object?> get props => [shareMyPositionData, contacts, contactLocationData, error];
}

@CopyWith()
class MyPositionSharing extends Equatable {

  final User contact;
  final int sharingSessionId;
  final DateTime sharedUntil;

  const MyPositionSharing({required this.contact, required this.sharingSessionId, required this.sharedUntil});

  @override
  List<Object?> get props => [contact, sharingSessionId, sharedUntil];

}
