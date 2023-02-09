abstract class BudgetReviewEvent {
  const BudgetReviewEvent();
}

class InitializeEvent extends BudgetReviewEvent {}

class SaveBudgetEvent extends BudgetReviewEvent{
  final String amount;

  const SaveBudgetEvent({required this.amount});
}

class YearBudgetEvent extends BudgetReviewEvent {
  final int year;

  const YearBudgetEvent({required this.year});
}