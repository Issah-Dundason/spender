import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/util/app_utils.dart';

import '../../model/bill.dart';

class ExpensesBloc extends Bloc<IExpensesEvent, IExpensesState> {
  final AppRepository appRepo;

  final _removers = [
    BillRemover(),
    RecurringBillRemover(),
    GeneratedBillRemover()
  ];

  ExpensesBloc({required this.appRepo})
      : super(ExpensesSuccessfulState(selectedDate: DateTime.now())) {
    on<ExpensesDateChangeEvent>(_onDateChange);
    on<ExpensesLoadingEvent>(_onLoad);
    on<ExpensesBillDeleteEvent>(_onDelete);
  }

  void _onDateChange(ExpensesDateChangeEvent e, Emitter<IExpensesState> emit) async {
    emit(const ExpensesLoadingState());

    var date = DateFormat("yyyy-MM-dd").format(e.selectedDate);
    var expenditures = await appRepo.getAllBills(date);
    int? year = await appRepo.getYearOfFirstInsert();

    var nextState = ExpensesSuccessfulState(
      selectedDate: e.selectedDate,
      yearOfFirstInsert: year,
      transactions: expenditures,
    );

    emit(nextState);
  }

  void _onLoad(IExpensesEvent e, Emitter<IExpensesState> emit) async {
    var selectedDate = DateTime.now();

    if(state is ExpensesSuccessfulState) {
      selectedDate = (state as ExpensesSuccessfulState).selectedDate;
    }

    emit(const ExpensesLoadingState());

    var date = DateFormat("yyyy-MM-dd").format(selectedDate);
    var expenditures = await appRepo.getAllBills(date);
    int? year = await appRepo.getYearOfFirstInsert();

    var nextState = ExpensesSuccessfulState(
      selectedDate: selectedDate,
      yearOfFirstInsert: year,
      transactions: expenditures,
    );

    emit(nextState);
  }

  int _getIndex(Bill bill) {
    return bill.isRecurring.toInt + bill.isGenerated.toInt;
  }

  void _onDelete(ExpensesBillDeleteEvent event, Emitter<IExpensesState> emit) async {
    var selectedDate = DateTime.now();

    if(state is ExpensesSuccessfulState) {
      selectedDate = (state as ExpensesSuccessfulState).selectedDate;
    }

    emit(const ExpensesLoadingState());
    await _removers[_getIndex(event.bill)].remove(appRepo, event);
    emit(const ExpensesDeletedState());

    var date = DateFormat("yyyy-MM-dd").format(selectedDate);
    var expenditures = await appRepo.getAllBills(date);
    int? year = await appRepo.getYearOfFirstInsert();

    var nextState = ExpensesSuccessfulState(
      selectedDate: selectedDate,
      yearOfFirstInsert: year,
      transactions: expenditures,
    );

    emit(nextState);
  }
}

class BillRemover {
  Future<void> remove(AppRepository repo, ExpensesBillDeleteEvent event) async {
    await repo.deleteBill(event.bill.id!);
  }
}

class RecurringBillRemover implements BillRemover {
  @override
  Future<void> remove(AppRepository repo, ExpensesBillDeleteEvent event) async {
    if (event.method == DeleteMethod.single) {
      await _onDeleteSingle(repo, event.bill);
      return;
    }
    await _onDeleteMultiple(repo, event.bill);
  }

  Future<void> _onDeleteSingle(AppRepository repo, Bill bill) async {
    if (bill.isLast) {
      await _onDeleteMultiple(repo, bill);
      return;
    }

    if (bill.exceptionId != null) {
      await repo.deleteGenerated(bill.exceptionId!);
      return;
    }

    DateTime date = DateTime.parse(bill.paymentDateTime);
    var exceptionDate = DateFormat('yyyy-MM-dd').format(date);

    await repo.createException({
      Bill.columnExceptionInstanceDate: exceptionDate,
      Bill.columnExceptionParentId: bill.id,
      "deleted": 1
    });
  }

  Future<void> _onDeleteMultiple(AppRepository repo, Bill bill) async {
    await repo.deleteBill(bill.id!);
    await repo.deleteAllExceptionsForParent(bill.id!);
  }
}

class GeneratedBillRemover implements BillRemover {
  @override
  Future<void> remove(AppRepository repo, ExpensesBillDeleteEvent event) async {
    if (event.method == DeleteMethod.multiple) {
      await _deleteMultipleBills(repo, event.bill);
      return;
    }
    await _deleteSingleBill(repo, event.bill);
  }

  Future<void> _deleteSingleBill(AppRepository repo, Bill bill) async {
    try {
      if (bill.isLast) {
        var end = await getLastDay(bill, repo);
        await repo.deleteParentExceptionAfterDate(
            bill.parentId!, end.toIso8601String());
        return;
      }
    } on UnavailableException {
      await repo.deleteBill(bill.parentId!);
      await repo.deleteAllExceptionsForParent(bill.parentId!);
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

  Future<void> _deleteMultipleBills(AppRepository repo, Bill bill) async {
    try {
      DateTime end = await getLastDay(bill, repo);

      await repo.deleteParentExceptionAfterDate(
        bill.parentId!,
        end.toIso8601String(),
      );
    } on UnavailableException {
      await repo.deleteBill(bill.parentId!);
      await repo.deleteAllExceptionsForParent(bill.parentId!);
    }
  }

  Future<DateTime> getLastDay(Bill bill, AppRepository repo) async {
    var lastPaymentDate =
        await repo.getLastEndDate(bill.parentId!, bill.paymentDateTime);
    var lastDate = DateUtils.dateOnly(DateTime.parse(lastPaymentDate));
    var end = lastDate.add(const Duration(hours: 23, minutes: 59));
    return end;
  }
}
