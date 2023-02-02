import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:spender/bloc/bill/billing_event.dart';
import 'package:spender/model/bill.dart';

import '../../repository/expenditure_repo.dart';
import 'billing_state.dart';

class BillBloc extends Bloc<BillEvent, BillingState> {
  final AppRepository appRepo;

  BillBloc({required this.appRepo}) : super(const BillingState()) {
    on<BillSaveEvent>(_onBillSave);
    on<BillUpdateEvent>(_onBillUpdate);
  }

  _onBillSave(BillSaveEvent e, Emitter<BillingState> emitter) async {
    emitter(const BillingState(processingState: ProcessingState.pending));
    await appRepo.saveExpenditure(e.expenditure);
    emitter(const BillingState(processingState: ProcessingState.done));
  }

  _onBillUpdate(BillUpdateEvent e, Emitter<BillingState> emitter) async {
    emitter(const BillingState(processingState: ProcessingState.pending));

    if (e.updateMethod == UpdateMethod.single && e.update.isGenerated()) {
      updateSingleGeneratedInstance(e.instanceDate!, e.update);
    } else if (e.updateMethod == UpdateMethod.multiple &&
        e.update.isGenerated()) {
      updateMultipleGeneratedInstance(e.instanceDate!, e.update);
    } else if (e.updateMethod == UpdateMethod.single &&
        !e.update.isGenerated()) {
      updateSingleInstance(e.update);
    } else {
      updateMultiple(e.update);
    }

    emitter(const BillingState(processingState: ProcessingState.done));
  }

  void updateSingleGeneratedInstance(String instanceDate, Bill update) async {
    if (update.exceptionId != null) {
      var exceptJson = update.toExceptionJson(instanceDate);
      appRepo.updateException(update.exceptionId!, exceptJson);
      appRepo.deleteParentExceptionAfterDate(update.parentId!, update.endDate!);
      return;
    }
    var exceptJson = update.toExceptionJson(instanceDate);
    appRepo.createException(exceptJson);
    appRepo.deleteParentExceptionAfterDate(update.parentId!, update.endDate!);
  }

  void updateMultipleGeneratedInstance(String instanceDate, Bill update) async {
    var parentEndDate = DateUtils.dateOnly(DateTime.parse(instanceDate))
        .subtract(const Duration(days: 1));
    parentEndDate = parentEndDate.add(const Duration(hours: 23, minutes: 59));

    appRepo.deleteParentExceptionAfterDate(
        update.parentId!, parentEndDate.toIso8601String());

    await appRepo.saveExpenditure(update);
  }

  void updateSingleInstance(Bill update) {

  }

  void updateMultiple(Bill update) {}
}
