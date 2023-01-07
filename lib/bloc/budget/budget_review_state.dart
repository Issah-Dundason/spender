import 'package:equatable/equatable.dart';

import '../../model/budget.dart';

enum BudgetingStat { none, pending, error, done }

class BudgetReviewState extends Equatable {
  final int selectedYear;
  final List<Budget> budgets;
  final int? firstYearOfBudgetEntry;
  final BudgetingStat budgetingState;

  const BudgetReviewState(
      {required this.selectedYear,
      this.budgets = const [],
      this.budgetingState = BudgetingStat.none,
      this.firstYearOfBudgetEntry});

  BudgetReviewState copyWith(
      {int? selectedYear,
      List<Budget>? budgets,
      int? firstYearOfBudgetEntry,
      BudgetingStat? stat}) {
    return BudgetReviewState(
        selectedYear: selectedYear ?? this.selectedYear,
        budgetingState: stat ?? budgetingState,
        budgets: budgets ?? this.budgets,
        firstYearOfBudgetEntry:
            firstYearOfBudgetEntry ?? this.firstYearOfBudgetEntry);
  }

  @override
  List<Object?> get props =>
      [selectedYear, budgets, firstYearOfBudgetEntry, budgetingState];
}
