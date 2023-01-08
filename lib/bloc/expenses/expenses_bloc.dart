
import 'package:bloc/bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  ExpensesBloc(): super(ExpensesState(selectedDate: DateTime.now())) {
    on<ChangeDateEvent>(_onDateChange);
  }

  void _onDateChange(ChangeDateEvent e, Emitter<ExpensesState> emitter) async {
    print('Expense me yaww');
  }
}