import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

import '../../repository/expenditure_repo.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, IHomeState> {
  final AppRepository appRepo;

  HomeBloc({required this.appRepo})
      : super(const HomeLoadingState()) {
    on<HomeInitializationEvent>(_onStartHandler);
    on<HomeAnalysisDateChangeEvent>(_onHandleAnalysisDateChange);
  }

  void _onStartHandler(HomeEvent event, Emitter<IHomeState> emit) async {
    emit(const HomeLoadingState());

    DateTime date = DateTime.now();
    var yearAndMonth = DateFormat("yyyy-MM").format(date);

    var expenditures = await appRepo.getAmountSpentEachMonth("${date.year}");
    var financials = await appRepo.getFinancials(yearAndMonth);
    var transactions = await appRepo.getBillAt(date, 3);
    var firstRecordYear = await appRepo.getYearOfFirstInsert();

    var newState = HomeSuccessFetchState(
      currentFinancials: financials,
      monthExpenditures: expenditures,
      transactionsToday: transactions,
      firstEverRecordYear: firstRecordYear,
    );

    emit(newState);
  }

  void _onHandleAnalysisDateChange(
    HomeAnalysisDateChangeEvent event,
    Emitter<IHomeState> emit,
  ) async {

    var record = await appRepo.getAmountSpentEachMonth('${event.year}');

    var oldState = state as HomeSuccessFetchState;

    emit(oldState.copyWith(monthSpending: record));
  }
}
