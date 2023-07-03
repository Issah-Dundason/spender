import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/budget/budget_review_event.dart';
import 'package:spender/util/app_utils.dart';

import '../../model/budget.dart';
import '../../repository/expenditure_repo.dart';
import 'budget_review_state.dart';

class BudgetReviewBloc extends Bloc<BudgetReviewEvent, IBudgetDataState> {
  final AppRepository appRepo;

  BudgetReviewBloc({required this.appRepo})
      : super(const BudgetDataLoadingState()) {
    on<InitializeEvent>(_onInitialize);
    on<SaveBudgetEvent>(_onSave);
    on<YearBudgetEvent>(_handleSelectedYearChange);
  }

  _onInitialize(InitializeEvent e, Emitter<IBudgetDataState> emit) async {
    int? first = await appRepo.getYearOfFirstBudget();
    var date = DateTime.now();

    var yearMonth = DateFormat("yyyy-MM").format(date);
    var budget = await appRepo.getBudget(yearMonth);

    if (budget != null) {
      var decimal = Decimal.fromInt(budget.amount);
      var actualAmount = decimal / Decimal.fromInt(100);

      emit(BudgetOfMonthFetched("$actualAmount"));
    }

    int year = date.year;
    var budgets = await appRepo.getBudgetsForYear('$year');

    final nextState = BudgetDataFetchedState(
      selectedYear: year,
      budgets: budgets,
      firstYearOfBudgetEntry: first,
    );

    emit(nextState);
  }

  _onSave(SaveBudgetEvent e, Emitter<IBudgetDataState> emit) async {
    var selectedYear = (state as BudgetDataFetchedState).selectedYear;

    DateTime date = DateTime.now();
    var yearAndMonth = DateFormat("yyyy-MM").format(date);
    var budget = await appRepo.getBudget(yearAndMonth);

    emit(const BudgetSavingState());

    if (budget == null) {
      await _saveBudgetForCurrentMonth(e);
    } else {
      int amount = AppUtils.getActualAmount(e.amount);
      var newBudget = budget.copyWith(amount: amount);
      await appRepo.updateBudget(newBudget);
    }

    emit(const BudgetSavedState());

    var budgets = await appRepo.getBudgetsForYear('$selectedYear');
    int? first = await appRepo.getYearOfFirstBudget();

    final nextState = BudgetDataFetchedState(
      selectedYear: selectedYear,
      budgets: budgets,
      firstYearOfBudgetEntry: first,
    );

    emit(nextState);
  }

  Future<void> _saveBudgetForCurrentMonth(SaveBudgetEvent e) async {
    int actualAmount = AppUtils.getActualAmount(e.amount);
    var date = DateTime.now();
    var s = DateTime(date.year, date.month);
    var budget = Budget(s.toIso8601String(), actualAmount);
    await appRepo.saveBudget(budget);
  }

  void _handleSelectedYearChange(
    YearBudgetEvent e,
    Emitter<IBudgetDataState> emit,
  ) async {
    var currentState = (state as BudgetDataFetchedState);

    var budgets = await appRepo.getBudgetsForYear('${currentState.selectedYear}');

    emit(currentState.copyWith(budgets: budgets));
  }
}
