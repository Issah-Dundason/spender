import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/bill/billing_event.dart';
import 'package:spender/model/bill.dart';
import 'package:spender/service/database.dart';

import '../../repository/expenditure_repo.dart';
import 'billing_state.dart';

class BillBloc extends Bloc<BillEvent, BillingState> {
  final AppRepository appRepo;

  BillBloc({required this.appRepo}) : super(const BillingState()) {
    on<BillSaveEvent>(_onBillSave);
    on<RecurrenceUpdateEvent>(_onRecurrenceUpdate);
    on<NonRecurringUpdateEvent>(_onNonRecurrenceUpdate);
  }

  void _onBillSave(BillSaveEvent e, Emitter<BillingState> emitter) async {
    emitter(const BillingState(processingState: ProcessingState.pending));
    await appRepo.saveBill(e.expenditure);
    emitter(const BillingState(processingState: ProcessingState.done));
  }

  void _onNonRecurrenceUpdate(
      NonRecurringUpdateEvent e, Emitter<BillingState> emitter) async {
    emitter(const BillingState(processingState: ProcessingState.pending));
    await appRepo.updateBill(e.update.id!, e.update.toNewBillJson());
    emitter(const BillingState(processingState: ProcessingState.done));
  }

  void _onRecurrenceUpdate(
      RecurrenceUpdateEvent e, Emitter<BillingState> emitter) async {
    emitter(const BillingState(processingState: ProcessingState.pending));

    if (e.update.isGenerated) {
      await updateGenerated(e);
      return;
    }
    await updateActualBillInstance(e);

    emitter(const BillingState(processingState: ProcessingState.done));
  }

  Future<void> updateGenerated(RecurrenceUpdateEvent e) async {
    if(e.updateMethod == UpdateMethod.single) {
      await updateSingleGeneratedInstance(e.instanceDate, e.update);
      return;
    }
    await updateMultipleGeneratedInstance(e.instanceDate, e.update);
  }

  Future<void> updateActualBillInstance(RecurrenceUpdateEvent e) async {
    if(e.updateMethod == UpdateMethod.single) {
      await updateSingleInstance(e.instanceDate, e.update);
      return;
    }
    updateMultiple(e.instanceDate, e.update);
  }

  Future<void> updateSingleGeneratedInstance(String instanceDate, Bill update) async {
    if (update.exceptionId != null) {
      var exceptJson = update.toExceptionJson(instanceDate);
      await appRepo.updateException(update.exceptionId!, exceptJson);
      await appRepo.deleteParentExceptionAfterDate(update.parentId!, update.endDate!);
      return;
    }
    var exceptJson = update.toExceptionJson(instanceDate);
    await appRepo.createException(exceptJson);
    await appRepo.deleteParentExceptionAfterDate(update.parentId!, update.endDate!);
  }

  Future<void> updateMultipleGeneratedInstance(String instanceDate, Bill update) async {

    try {
      DateTime end = await getLastDay(update);

      await appRepo.deleteParentExceptionAfterDate(
        update.parentId!,
        end.toIso8601String(),
      );
    } on UnavailableException {
      await appRepo.deleteBill(update.parentId!);
      await appRepo.deleteAllExceptionsForParent(update.parentId!);
    }

    await appRepo.saveBill(update);
  }

  Future<DateTime> getLastDay(Bill bill) async {
    var billDate = DateTime.parse(bill.paymentDateTime);
    String date = DateFormat('yyyy-MM-dd').format(billDate);
    var lastPaymentDate = await appRepo.getLastEndDate(bill.parentId!, date);

    var lastDate = DateUtils.dateOnly(DateTime.parse(lastPaymentDate));

    var end = lastDate.add(const Duration(hours: 23, minutes: 59));
    return end;
  }

  Future<void> updateSingleInstance(String instanceDate, Bill update) async {
    if (update.exceptionId != null) {
      var exceptJson = update.toExceptionJson(instanceDate);
      exceptJson[Bill.columnExceptionParentId] = update.id;
      await appRepo.updateException(update.exceptionId!, exceptJson);
      await appRepo.deleteParentExceptionAfterDate(update.id!, update.endDate!);
      return;
    }
    var exceptJson = update.toExceptionJson(instanceDate);
    exceptJson[Bill.columnExceptionParentId] = update.id;
    await appRepo.createException(exceptJson);
    await appRepo.deleteParentExceptionAfterDate(update.id!, update.endDate!);
  }

  Future<void> updateMultiple(String instanceDate, Bill update) async {
    await appRepo.updateBill(update.id!, update.toNewBillJson());
    await appRepo.deleteAllExceptionsForParent(update.id!);
  }

}

