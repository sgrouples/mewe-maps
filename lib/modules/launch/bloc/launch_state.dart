import 'package:equatable/equatable.dart';
import 'package:mewe_maps/models/user.dart';

class LaunchState extends Equatable {
  final bool initialized;
  final User? user;

  const LaunchState({required this.initialized, this.user});

  @override
  List<Object?> get props => [initialized, user];
}
