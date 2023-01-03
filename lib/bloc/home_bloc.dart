import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

import '../repository/expenditure_repo.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AppRepository appRepo;

  HomeBloc({required this.appRepo}) : super(const HomeState()) {
    on<HomeInitializationEvent>(_onStartHandler);
  }

  void _onStartHandler(HomeEvent event, Emitter<HomeState> emit)  async {
    DateTime date = DateTime.now();
    var year = "${date.year}";
    var yearAndMonth = DateFormat("yyyy-MM").format(date);
    var expenditures = await appRepo.getAmountSpentEachMonth(year);
    var financials = await appRepo.getFinancials(yearAndMonth);
    //print('length: ${spendings.length}: month: ${spendings[0].month}');
    emit(state.copyWith(monthSpending: expenditures));
  }
}