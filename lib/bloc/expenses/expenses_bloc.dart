import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:spender/repository/expenditure_repo.dart';

import '../../model/bill.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final AppRepository appRepo;

  ExpensesBloc({required this.appRepo})
      : super(ExpensesState(selectedDate: DateTime.now())) {
    on<ChangeDateEvent>(_onDateChange);
    on<OnStartEvent>(_onStart);
    on<LoadEvent>(_onLoad);
    on<RecurrentDeleteEvent>(_onRecurrentDelete);
    on<NonRecurringDelete>(_onNonRecurringDelete);
  }

  void _onDateChange(ChangeDateEvent e, Emitter<ExpensesState> emitter) async {
    var date = DateFormat("yyyy-MM-dd").format(e.selectedDate);
    var expenditures = await appRepo.getAllBills(date);
    emitter(state.copyWith(
        selectedDate: e.selectedDate, transactions: expenditures));
  }

  void _onStart(OnStartEvent e, Emitter<ExpensesState> emitter) async {
    int? year = await appRepo.getYearOfFirstInsert();
    emitter(state.copyWith(yearOfFirstInsert: year, initialized: true));
  }

  void _onLoad(ExpensesEvent e, Emitter<ExpensesState> emitter) async {
    emitter(state.copyWith(transactions: []));
    var date = DateFormat("yyyy-MM-dd").format(state.selectedDate);
    var expenditures = await appRepo.getAllBills(date);
    emitter(state.copyWith(transactions: expenditures));
  }

  void _onRecurrentDelete(
      RecurrentDeleteEvent e, Emitter<ExpensesState> emitter) {
    emitter(state.copyWith(deleteState: DeleteState.deleting));
    if (e.bill.isGenerated() && e.method == DeleteMethod.single) {
      _onDeleteSingleGenerated(e.bill);
    } else if (e.bill.isGenerated() && e.method == DeleteMethod.multiple) {
      _onDeleteMultipleGenerated(e.bill);
    } else if (!e.bill.isGenerated() && e.method == DeleteMethod.single) {
      _onDeleteSingle(e.bill);
    } else {
      _onDeleteMultiple();
    }
    emitter(state.copyWith(deleteState: DeleteState.deleted));
  }

  void _onNonRecurringDelete(
      NonRecurringDelete e, Emitter<ExpensesState> emitter) {
    print('Non recurring');
  }

  void _onDeleteSingleGenerated(Bill bill) {
    if (bill.exceptionId != null) {
      appRepo.deleteGenerated(bill.exceptionId!);
      return;
    }

    DateTime date = DateTime.parse(bill.paymentDateTime);
    var exceptionDate = DateFormat('yyyy-MM-dd').format(date);

    appRepo.createException({
      Bill.columnExceptionInstanceDate: exceptionDate,
      Bill.columnExceptionParentId: bill.parentId,
      "deleted": 1
    });
  }

  void _onDeleteMultipleGenerated(Bill bill) {
    var parentEndDate = DateUtils.dateOnly(DateTime.parse(bill.paymentDateTime))
        .subtract(const Duration(days: 1));
    parentEndDate = parentEndDate.add(const Duration(hours: 23, minutes: 59));

    appRepo.deleteParentExceptionAfterDate(
        bill.parentId!, parentEndDate.toIso8601String());
  }

  void _onDeleteSingle(Bill bill) {
    if (bill.exceptionId != null) {
      appRepo.deleteGenerated(bill.exceptionId!);
      return;
    }

    DateTime date = DateTime.parse(bill.paymentDateTime);
    var exceptionDate = DateFormat('yyyy-MM-dd').format(date);

    appRepo.createException({
      Bill.columnExceptionInstanceDate: exceptionDate,
      Bill.columnExceptionParentId: bill.id,
      "deleted": 1
    });
  }

  void _onDeleteMultiple() {
    print('recurring not generate multiple');
  }
}
