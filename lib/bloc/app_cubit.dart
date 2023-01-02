import 'package:bloc/bloc.dart';

import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  set currentState(AppState state) => emit(state);
}