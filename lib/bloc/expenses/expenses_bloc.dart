import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/util/app_utils.dart';

import '../../model/bill.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final AppRepository appRepo;

  final _removers = [
    BillRemover(),
    RecurringBillRemover(),
    GeneratedBillRemover()
  ];

  ExpensesBloc({required this.appRepo})
      : super(ExpensesState(selectedDate: DateTime.now())) {
    on<ChangeDateEvent>(_onDateChange);
    on<OnStartEvent>(_onStart);
    on<LoadEvent>(_onLoad);
    on<BillDeleteEvent>(_onDelete);
  }

  void _onDateChange(ChangeDateEvent e, Emitter<ExpensesState> emitter) async {
    emitter(state.copyWith(deleteState: DeleteState.none));
    var date = DateFormat("yyyy-MM-dd").format(e.selectedDate);
    var expenditures = await appRepo.getAllBills(date);
    emitter(state.copyWith(
        selectedDate: e.selectedDate, transactions: expenditures));
  }

  void _onStart(OnStartEvent e, Emitter<ExpensesState> emitter) async {
    emitter(state.copyWith(deleteState: DeleteState.none));
    int? year = await appRepo.getYearOfFirstInsert();
    emitter(state.copyWith(yearOfFirstInsert: year, initialized: true));
  }

  void _onLoad(ExpensesEvent e, Emitter<ExpensesState> emitter) async {
    emitter(state.copyWith(transactions: [], deleteState: DeleteState.none));
    var date = DateFormat("yyyy-MM-dd").format(state.selectedDate);
    var expenditures = await appRepo.getAllBills(date);
    int? year = await appRepo.getYearOfFirstInsert();
    emitter(
        state.copyWith(transactions: expenditures, yearOfFirstInsert: year));
  }

  int _getIndex(Bill bill) {
    return bill.isRecurring.toInt + bill.isGenerated.toInt;
  }

  void _onDelete(BillDeleteEvent event, Emitter<ExpensesState> emit) {
    emit(state.copyWith(deleteState: DeleteState.deleting));
    _removers[_getIndex(event.bill)].remove(appRepo, event);
    emit(state.copyWith(deleteState: DeleteState.deleted));
  }
}

class BillRemover {
  void remove(AppRepository repo, BillDeleteEvent event) {
    repo.deleteBill(event.bill.id!);
  }
}

class RecurringBillRemover implements BillRemover {
  @override
  void remove(AppRepository repo, BillDeleteEvent event) {
    if (event.method == DeleteMethod.single) {
      _onDeleteSingle(repo, event.bill);
      return;
    }
    _onDeleteMultiple(repo, event.bill);
  }

  void _onDeleteSingle(AppRepository repo, Bill bill) {
    var end = DateTime.parse(bill.endDate!);
    var start = DateTime.parse(bill.paymentDateTime);

    if (DateUtils.isSameDay(end, start)) {
      _onDeleteMultiple(repo, bill);
      return;
    }

    if (bill.exceptionId != null) {
      repo.deleteGenerated(bill.exceptionId!);
      return;
    }

    DateTime date = DateTime.parse(bill.paymentDateTime);
    var exceptionDate = DateFormat('yyyy-MM-dd').format(date);

    repo.createException({
      Bill.columnExceptionInstanceDate: exceptionDate,
      Bill.columnExceptionParentId: bill.id,
      "deleted": 1
    });
  }

  void _onDeleteMultiple(AppRepository repo, Bill bill) {
    repo.deleteBill(bill.id!);
    repo.deleteAllExceptionsForParent(bill.id!);
  }
}

class GeneratedBillRemover implements BillRemover {
  @override
  void remove(AppRepository repo, BillDeleteEvent event) {
    if (event.method == DeleteMethod.multiple) {
      _deleteMultipleBills(repo, event.bill);
      return;
    }
    _deleteSingleBill(repo, event.bill);
  }

  void _deleteSingleBill(AppRepository repo, Bill bill) async {

    if (bill.isLast) {
      var end = await getLastDay(bill, repo);
      repo.deleteParentExceptionAfterDate(
          bill.parentId!, end.toIso8601String());
      return;
    }

    if (bill.exceptionId != null) {
      repo.deleteGenerated(bill.exceptionId!);
      return;
    }

    DateTime date = DateTime.parse(bill.paymentDateTime);
    var exceptionDate = DateFormat('yyyy-MM-dd').format(date);

    repo.createException({
      Bill.columnExceptionInstanceDate: exceptionDate,
      Bill.columnExceptionParentId: bill.parentId,
      "deleted": 1
    });
  }

  void _deleteMultipleBills(AppRepository repo, Bill bill) async {

    DateTime end = await getLastDay(bill, repo);

    repo.deleteParentExceptionAfterDate(
      bill.parentId!,
      end.toIso8601String(),
    );
  }

  Future<DateTime> getLastDay(Bill bill, AppRepository repo) async {
    var billDate = DateTime.parse(bill.paymentDateTime);
    String date = DateFormat('yyyy-MM-dd').format(billDate);
    var lastPaymentDate = await repo.getLastEndDate(bill.parentId!, date);

    var lastDate = DateUtils.dateOnly(DateTime.parse(lastPaymentDate));

    var end = lastDate.add(const Duration(hours: 23, minutes: 59));
    return end;
  }
}
