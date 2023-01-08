import 'package:bloc/bloc.dart';
import 'package:spender/bloc/bill/billing_event.dart';

import '../../repository/expenditure_repo.dart';
import 'billing_state.dart';

class BillBloc extends Bloc<BillEvent, BillingState> {
  final AppRepository appRepo;

  BillBloc({required this.appRepo})
      : super(const BillingState()) {
    on<BillSaveEvent>(_onBillSave);
    on<BillUpdateEvent>(_onBillUpdate);
  }

  _onBillSave(BillSaveEvent e, Emitter<BillingState> emitter) async {
    emitter(const BillingState(processingState: ProcessingState.pending));
    await appRepo.saveExpenditure(e.expenditure);
    emitter(const BillingState(processingState: ProcessingState.done));
  }

  _onBillUpdate(BillUpdateEvent e, Emitter<BillingState> emitter) async {
    print('updating');
  }
}
