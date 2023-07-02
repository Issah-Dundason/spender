import 'package:equatable/equatable.dart';

import '../../model/budget.dart';

abstract class IBudgetDataState extends Equatable {
  const IBudgetDataState();

  @override
  List<Object?> get props => [];
}

class BudgetDataLoadingState extends IBudgetDataState {
  const BudgetDataLoadingState();
}

class BudgetSavingState extends IBudgetDataState {
  const BudgetSavingState();
}

class BudgetSavedState extends IBudgetDataState {
  const BudgetSavedState();
}

class BudgetOfMonthFetched extends IBudgetDataState {
  final String amount;

  const BudgetOfMonthFetched(this.amount);
}

class BudgetDataFetchedState extends IBudgetDataState {
  final int selectedYear;
  final List<Budget> budgets;
  final int? firstYearOfBudgetEntry;

  const BudgetDataFetchedState({
    required this.selectedYear,
    this.budgets = const [],
    this.firstYearOfBudgetEntry,
  });

  BudgetDataFetchedState copyWith({
    int? selectedYear,
    List<Budget>? budgets,
    int? firstYearOfBudgetEntry,
  }) {
    return BudgetDataFetchedState(
      selectedYear: selectedYear ?? this.selectedYear,
      budgets: budgets ?? this.budgets,
      firstYearOfBudgetEntry:
          firstYearOfBudgetEntry ?? this.firstYearOfBudgetEntry,
    );
  }

  @override
  List<Object?> get props => [selectedYear, budgets, firstYearOfBudgetEntry];
}
