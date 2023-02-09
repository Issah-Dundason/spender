
import '../../model/bill.dart';

abstract class ExpensesEvent {
  const ExpensesEvent();
}

class ChangeDateEvent extends ExpensesEvent {
  final DateTime selectedDate;

  ChangeDateEvent(this.selectedDate);
}

class OnStartEvent extends ExpensesEvent {
  const OnStartEvent();
}

class LoadEvent extends ExpensesEvent {
  const LoadEvent();
}

enum DeleteMethod {
  single,
  multiple
}

class RecurrentDeleteEvent extends ExpensesEvent {
 final DeleteMethod method;
 final Bill bill;

 RecurrentDeleteEvent({this.method = DeleteMethod.single, required this.bill});
}

class NonRecurringDelete extends ExpensesEvent {
  final Bill bill;

  NonRecurringDelete(this.bill);
}


