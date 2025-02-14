import 'package:bloc/bloc.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState().init()) {
    on<InitEvent>(init);
  }

  void init(InitEvent event, Emitter<AppState> emit) async {
    emit(state.clone());
  }
}
