import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:spender/bloc/bill/billing_event.dart';
import 'package:spender/model/bill.dart';
import 'package:spender/service/database.dart';

import '../../repository/expenditure_repo.dart';
import 'billing_state.dart';

class BillBloc extends Bloc<IBillEvent, IBillingState> {
  final AppRepository appRepo;

  BillBloc({required this.appRepo}) : super(const InitialBillingState()) {
    on<BillSaveEvent>(_onBillSave);
    on<RecurringBillUpdateEvent>(_onRecurrenceUpdate);
    on<NonRecurringBillUpdateEvent>(_onNonRecurrenceUpdate);
    on<BillTypesFetchEvent>(_onFetchEvents);
    on<BillUpdateEvent>(_onBillUpdate);
  }

  void _onFetchEvents(BillTypesFetchEvent e, Emitter<IBillingState> emit) async {
    var types = await appRepo.getBillTypes();
    emit(BillTypesFetchedState(types));
  }

  void _onBillSave(BillSaveEvent e, Emitter<IBillingState> emit) async {
    emit(const BillSavingState());
    await appRepo.saveBill(e.bill);
    emit(const BillSavedState());
  }

  void _onBillUpdate(BillUpdateEvent e, Emitter<IBillingState> emit) {
    emit(BillUpdateState(e.bill));
  }

  void _onNonRecurrenceUpdate(
      NonRecurringBillUpdateEvent e, Emitter<IBillingState> emit) async {
    emit(const BillSavingState());
    await appRepo.updateBill(e.update.id!, e.update.toNewBillJson());
    emit(const BillUpdatedState());
  }

  void _onRecurrenceUpdate(
      RecurringBillUpdateEvent e, Emitter<IBillingState> emit) async {
    emit(const BillSavingState());

    if (e.update.isGenerated) {
      await updateGenerated(e);
    } else {
      await updateActualBillInstance(e);
    }
    emit(const BillUpdatedState());
 }

  Future<void> updateGenerated(RecurringBillUpdateEvent e) async {
    if(e.updateMethod == UpdateMethod.single) {
      await updateSingleGeneratedInstance(e.instanceDate, e.update);
      return;
    }
    await updateMultipleGeneratedInstance(e.instanceDate, e.update);
  }

  Future<void> updateActualBillInstance(RecurringBillUpdateEvent e) async {
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
    var lastPaymentDate = await appRepo.getLastEndDate(bill.parentId!, bill.paymentDateTime);
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

