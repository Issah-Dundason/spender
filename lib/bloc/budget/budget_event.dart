abstract class BudgetEvent {
  const BudgetEvent();
}

class InitializeEvent extends BudgetEvent {}

class SaveBudgetEvent extends BudgetEvent{
  final String amount;

  const SaveBudgetEvent({required this.amount});
}