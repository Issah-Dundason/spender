abstract class ExpensesEvent {
  const ExpensesEvent();
}

class ChangeDateEvent extends ExpensesEvent {
  final DateTime selectedDate;

  ChangeDateEvent(this.selectedDate);
}
