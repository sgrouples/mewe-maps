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

@CopyWith()
class MapState extends Equatable {
  const MapState({
    required this.mapInitialized,
    this.showPermissionsRationale = false,
    this.selectedUser,
    this.myPosition,
    this.contactsPositions = const [],
    this.trackingState = TrackingState.notTracking,
  });

  final bool mapInitialized;
  final bool showPermissionsRationale;
  final UserPosition? selectedUser;

  final UserPosition? myPosition;
  final List<UserPosition> contactsPositions;
  final TrackingState trackingState;

  @override
  List<Object?> get props => [
        mapInitialized,
        showPermissionsRationale,
        selectedUser,
        myPosition,
        contactsPositions,
        trackingState
      ];
}

enum TrackingState {
  myPosition,
  selectedUser,
  notTracking,
}
