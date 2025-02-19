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
  List<Object?> get props => [mapInitialized, showPermissionsRationale, selectedUser, myPosition, contactsPositions, trackingState];
}

enum TrackingState {
  myPosition,
  selectedUser,
  notTracking,
}
