part of 'map_bloc.dart';

@CopyWith()
class MapState extends Equatable {
  const MapState({
    required this.mapInitialized,
    this.showPermissionsRationale = false,
    this.selectedUser,
  });

  final bool mapInitialized;
  final bool showPermissionsRationale;
  final UserPosition? selectedUser;

  @override
  List<Object?> get props => [mapInitialized, showPermissionsRationale, selectedUser];
}
