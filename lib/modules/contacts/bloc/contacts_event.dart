part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {}

class StartObservingData extends ContactsEvent {
  @override
  List<Object?> get props => ['LoadContacts'];
}

class ShareMyPositionStarted extends ContactsEvent {
  final User contact;
  final int minutes;

  ShareMyPositionStarted(this.contact, this.minutes);

  @override
  List<Object?> get props => [contact, minutes];
}

class ShareMyPositionStopped extends ContactsEvent {
  final int sessionId;

  ShareMyPositionStopped(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class ShareMyPositionChanged extends ContactsEvent {
  final List<MyPositionSharing>? shareMyPositionData;
  final List<User>? contacts;

  ShareMyPositionChanged(this.shareMyPositionData, this.contacts);

  @override
  List<Object?> get props => [shareMyPositionData, contacts];
}

class ContactLocationDataChanged extends ContactsEvent {
  final Map<User, bool>? contactLocationData;

  ContactLocationDataChanged(this.contactLocationData);

  @override
  List<Object?> get props => [contactLocationData];
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
