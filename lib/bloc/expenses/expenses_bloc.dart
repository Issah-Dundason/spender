import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:spender/repository/expenditure_repo.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final AppRepository appRepo;

  ExpensesBloc({required this.appRepo})
      : super(ExpensesState(selectedDate: DateTime.now())) {
    on<ChangeDateEvent>(_onDateChange);
  }

  void _onDateChange(ChangeDateEvent e, Emitter<ExpensesState> emitter) async {
    print('Expense me yaww');
    var date = DateFormat("yyyy-MM-dd").format(e.selectedDate);
    var expenditures = await appRepo.getAllExpenditure(date);
    emitter(ExpensesState(
        selectedDate: e.selectedDate, transactions: expenditures));
  }
}
