import 'package:equatable/equatable.dart';

import '../../model/budget.dart';

enum BudgetingStat { none, pending, error, done }

class BudgetState extends Equatable {
  final int selectedYear;
  final List<Budget> budgets;
  final int? firstYearOfBudgetEntry;
  final BudgetingStat budgetingState;

  const BudgetState(
      {required this.selectedYear,
      this.budgets = const [],
      this.budgetingState = BudgetingStat.none,
      this.firstYearOfBudgetEntry});

  BudgetState copyWith(
      {int? selectedYear,
      List<Budget>? budgets,
      int? firstYearOfBudgetEntry,
      BudgetingStat? stat}) {
    return BudgetState(
        selectedYear: selectedYear ?? this.selectedYear,
        budgetingState: stat ?? budgetingState,
        budgets: budgets ?? this.budgets,
        firstYearOfBudgetEntry:
            firstYearOfBudgetEntry ?? this.firstYearOfBudgetEntry);
  }

  @override
  List<Object?> get props => [selectedYear, budgets, firstYearOfBudgetEntry, budgetingState];
}
