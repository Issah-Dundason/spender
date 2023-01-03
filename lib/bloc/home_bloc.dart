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

  void _onStartHandler(HomeEvent event, Emitter<HomeState> emit) async {
    DateTime date = DateTime.now();
    var year = "${date.year}";
    var yearAndMonth = DateFormat("yyyy-MM").format(date);
    var yearMonthDay = DateFormat("yyyy-MM-dd").format(date);
    var expenditures = await appRepo.getAmountSpentEachMonth(year);
    var financials = await appRepo.getFinancials(yearAndMonth);
    var transactions = await appRepo.getExpenditureAt(yearMonthDay, 4);
    emit(state.copyWith(
        monthSpending: expenditures,
        transactions: transactions,
        financials: financials));
  }
}
