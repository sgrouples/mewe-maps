// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {}

class InitEvent extends MapEvent {
  @override
  List<Object?> get props => ['InitEvent'];
}

class ObserveMyPosition extends MapEvent {
  @override
  List<Object?> get props => ['ObserveMyPosition'];
}

class StopObservingMyPosition extends MapEvent {
  @override
  List<Object?> get props => ['StopObservingMyPosition'];
}

class ShowPermissionsRationale extends MapEvent {
  @override
  List<Object?> get props => ['ShowPermissionsRationale'];
}

class RequestAllPermissions extends MapEvent {
  @override
  List<Object?> get props => ['RequestAllPermissions'];
}

class UpdateMyPosition extends MapEvent {
  final UserPosition? position;

  UpdateMyPosition(this.position);

  @override
  List<Object?> get props => [position];
}

class UpdateContactsLocation extends MapEvent {
  final List<UserPosition> positions;

  UpdateContactsLocation(this.positions);

  @override
  List<Object?> get props => [positions];
}

class UpdateLocationRequests extends MapEvent {
  final List<LocationRequest> locationRequests;

  UpdateLocationRequests(this.locationRequests);

  @override
  List<Object?> get props => [locationRequests];
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

class UserClicked extends MapEvent {
  final UserPosition userPosition;

  UserClicked(this.userPosition);

  @override
  List<Object?> get props => [userPosition];
}

class UserSelectedFromContacts extends MapEvent {
  final User user;

  UserSelectedFromContacts(this.user);

  @override
  List<Object?> get props => [user];
}

class TrackMyPositionClicked extends MapEvent {
  @override
  List<Object?> get props => ['TrackMyPositionClicked'];
}

class TrackSelectedUserClicked extends MapEvent {
  @override
  List<Object?> get props => ['TrackSelectedUserClicked'];
}

class CloseSelectedUser extends MapEvent {
  @override
  List<Object?> get props => ['CloseSelectedUser'];
}

class PreviousUserClicked extends MapEvent {
  @override
  List<Object?> get props => ['PreviousUserClicked'];
}

class NextUserClicked extends MapEvent {
  @override
  List<Object?> get props => ['NextUserClicked'];
}

class RespondForLocationRequest extends MapEvent {
  final LocationRequest request;
  final User user;
  final int? minutesToShare;

  RespondForLocationRequest(this.request, this.user, this.minutesToShare);

  @override
  List<Object?> get props => [request, user, minutesToShare];
}
