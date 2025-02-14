import 'package:bloc/bloc.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';

import 'launch_event.dart';
import 'launch_state.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  LaunchBloc() : super(const LaunchState(initialized: false)) {
    on<InitEvent>((event, emit) async {
      final user = StorageRepository.user;
      if (user != null) {
        emit(LaunchState(initialized: true, user: user));
      } else {
        emit(const LaunchState(initialized: true));
      }
    });
  }
}
