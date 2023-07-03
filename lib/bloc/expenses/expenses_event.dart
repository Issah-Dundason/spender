
import '../../model/bill.dart';

abstract class IExpensesEvent {
  const IExpensesEvent();
}

class ExpensesDateChangeEvent extends IExpensesEvent {
  final DateTime selectedDate;

  ExpensesDateChangeEvent(this.selectedDate);
}

class ExpensesInitialization extends IExpensesEvent {
  const ExpensesInitialization();
}

class ExpensesLoadingEvent extends IExpensesEvent {
  const ExpensesLoadingEvent();
}

enum DeleteMethod {
  single,
  multiple
}

class ExpensesBillDeleteEvent extends IExpensesEvent {
 final DeleteMethod method;
 final Bill bill;

 ExpensesBillDeleteEvent({this.method = DeleteMethod.single, required this.bill});
}


