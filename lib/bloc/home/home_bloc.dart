import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

import '../../repository/expenditure_repo.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AppRepository appRepo;

  HomeBloc({required this.appRepo})
      : super(HomeState(analysisYear: DateTime.now().year)) {
    on<HomeInitializationEvent>(_onStartHandler);
    on<HomeAnalysisDateChangeEvent>(_onHandleAnalysisDateChange);
  }

  void _onStartHandler(HomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(transactions: []));
    DateTime date = DateTime.now();
    var yearAndMonth = DateFormat("yyyy-MM").format(date);
    emit(state.copyWith(loadingState: DataLoading.pending));
    var expenditures =
        await appRepo.getAmountSpentEachMonth("${state.analysisYear}");
    var financials = await appRepo.getFinancials(yearAndMonth);
    var transactions = await appRepo.getExpenditureAt(date, 3);
    var firstRecordYear = await appRepo.getYearOfFirstInsert();
    emit(state.copyWith(
      loadingState: DataLoading.done,
        firstEverRecordYear: firstRecordYear,
        monthSpending: expenditures,
        transactions: transactions,
        financials: financials));
  }

  void _onHandleAnalysisDateChange(
      HomeAnalysisDateChangeEvent event, Emitter<HomeState> e) async {
    var record = await appRepo.getAmountSpentEachMonth('${event.year}');
    e(state.copyWith(monthSpending: record, analysisYear: event.year));
  }
}
