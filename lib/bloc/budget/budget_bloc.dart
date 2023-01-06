import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/budget/budget_event.dart';
import 'package:spender/util/app_utils.dart';

import '../../model/budget.dart';
import '../../repository/expenditure_repo.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {

  final AppRepository appRepo;

  BudgetBloc({required this.appRepo}) : super(BudgetState(selectedYear: DateTime
      .now()
      .year)) {
    on<InitializeEvent>(_onInitialize);
    on<SaveBudgetEvent>(_onSave);
    on<YearBudgetEvent>(_handleSelectedYearChange);
  }

  _onInitialize(InitializeEvent e, Emitter<BudgetState> emitter) async {
    int? first = await appRepo.getYearOfFirstBudget();
    var budgets = await appRepo.getBudgetsForYear('${state.selectedYear}');
    emitter(state.copyWith(firstYearOfBudgetEntry: first,
        budgets: budgets));
  }

  _onSave(SaveBudgetEvent e, Emitter<BudgetState> emitter) async {
    DateTime date = DateTime.now();
    var yearAndMonth = DateFormat("yyyy-MM").format(date);
    var budget = await appRepo.getBudget(yearAndMonth);
    emitter(state.copyWith(stat: BudgetingStat.pending));
    if(budget == null) {
      await _saveBudgetForCurrentMonth(e);
    } else {
      int amount = AppUtils.getActualAmount(e.amount);
      var newBudget = budget.copyWith(amount: amount);
      await appRepo.updateBudget(newBudget);
    }
    emitter(state.copyWith(stat: BudgetingStat.done));
    if(date.year != state.selectedYear) return;
    var budgets = await appRepo.getBudgetsForYear('${state.selectedYear}');
    emitter(state.copyWith(budgets: budgets));
  }

  Future<void> _saveBudgetForCurrentMonth(SaveBudgetEvent e) async {
    int r = AppUtils.getActualAmount(e.amount);
    var date = DateTime.now();
    var s = DateTime.utc(date.year, date.month);
    var budget = Budget(s.toIso8601String(), r);
    await appRepo.saveBudget(budget);
  }

  void _handleSelectedYearChange(YearBudgetEvent e, Emitter<BudgetState> emitter) async {
    var budgets = await appRepo.getBudgetsForYear('${e.year}');
    emitter(state.copyWith(budgets: budgets, selectedYear: e.year));
  }

}