import 'dart:async';

import 'package:bloc/bloc.dart';

import '../repository/expenditure_repo.dart';
import 'app_event.dart';
import 'app_state.dart';


class AppBloc extends Bloc<AppEvent, AppState> {
  final AppRepository appRepo;

  AppBloc({required this.appRepo}) : super(const AppState()) {
    on<AppStart>(_onStartHandler);
  }

  void _onStartHandler(AppEvent event,Emitter<AppState> emitter) {

  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(): super(const HomeState());

  set currentState(HomeState state) => emit(state);
}