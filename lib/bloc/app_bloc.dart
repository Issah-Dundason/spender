import 'dart:async';

import 'package:bloc/bloc.dart';

import '../repository/expenditure_repo.dart';
import 'app_event.dart';
import 'app_state.dart';


class AppBloc extends Bloc<AppEvent, AppState> {
  final AppRepository appRepo;

  AppBloc({required this.appRepo}) : super(const AppState(null)) {
    on<AppStart>(_onStartHandler);
  }

  void _onStartHandler(AppEvent event,Emitter<AppState> emitter) {

  }
}

class HomeCubit extends Cubit<HomeTabs> {
  HomeCubit(): super(HomeTabs.home);

  set tab(HomeTabs tab) => emit(tab);
}