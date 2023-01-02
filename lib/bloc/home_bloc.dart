import 'package:bloc/bloc.dart';

import '../repository/expenditure_repo.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AppRepository appRepo;

  HomeBloc({required this.appRepo}) : super(const HomeState()) {
    on<HomeOpenEvent>(_onStartHandler);
  }

  void _onStartHandler(HomeEvent event, Emitter<HomeState> emit) {}
}