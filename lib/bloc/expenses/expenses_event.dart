
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

class BillDeleteEvent extends ExpensesEvent {
 final DeleteMethod method;
 final Bill bill;

 BillDeleteEvent({this.method = DeleteMethod.single, required this.bill});
}


