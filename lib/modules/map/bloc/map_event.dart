part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {}

class InitEvent extends MapEvent {
  @override
  List<Object?> get props => ['InitEvent'];
}

class ObserveMyPosition extends MapEvent {
  @override
  List<Object?> get props => ['OnResume'];
}

class StopObservingMyPosition extends MapEvent {
  @override
  List<Object?> get props => ['OnPause'];
}

class UpdateMyPosition extends MapEvent {
  final UserPosition? position;

  UpdateMyPosition(this.position);

  @override
  List<Object?> get props => [
        [position]
      ];
}

class UpdateContactsLocation extends MapEvent {
  final List<UserPosition> positions;

  UpdateContactsLocation(this.positions);

  @override
  List<Object?> get props => [positions];
}

class OpenMeWeClicked extends MapEvent {
  final UserPosition position;

  OpenMeWeClicked(this.position);

  @override
  List<Object?> get props => [position];
}

class NavigateClicked extends MapEvent {
  final UserPosition userPosition;

  NavigateClicked(this.userPosition);

  @override
  List<Object?> get props => [userPosition];
}

class GeopointClicked extends MapEvent {
  final GeoPoint geoPoint;

  GeopointClicked(this.geoPoint);

  @override
  List<Object?> get props => [geoPoint];
}

class CloseSelectedUser extends MapEvent {

  CloseSelectedUser();

  @override
  List<Object?> get props => [];
}

class PreviousUserClicked extends MapEvent {
  @override
  List<Object?> get props => [];
}

class NextUserClicked extends MapEvent {
  @override
  List<Object?> get props => [];
}
