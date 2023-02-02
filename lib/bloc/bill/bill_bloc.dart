import 'package:bloc/bloc.dart';
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
   // e.update.isGenerated();
    print('called : ${e.update.isGenerated()}');
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

  void updateSingleGeneratedInstance(String instanceDate, Bill update) {
    if (update.exceptionId != null) {
      var exceptJson = update.toExceptionJson(instanceDate);
      print(exceptJson);
      appRepo.updateException(update.exceptionId!, update.toJson());
      return;
    }
    var exceptJson = update.toExceptionJson(instanceDate);
    print(exceptJson);
    appRepo.createException(update.toJson());
  }

  void updateMultipleGeneratedInstance(String instanceDate, Bill update) {}

  void updateSingleInstance(Bill update) {}

  void updateMultiple(Bill update) {}
}
