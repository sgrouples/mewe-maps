part of 'map_bloc.dart';

@CopyWith()
class MapState extends Equatable {
  const MapState({
    required this.mapInitialized,
    this.selectedUser,
  });

  final bool mapInitialized;
  final UserPosition? selectedUser;

  @override
  List<Object?> get props => [mapInitialized, selectedUser];
}
