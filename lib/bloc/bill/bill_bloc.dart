import 'package:bloc/bloc.dart';
import 'package:spender/bloc/bill/billing_event.dart';

import '../../repository/expenditure_repo.dart';
import 'billing_state.dart';

class BillBloc extends Bloc<BillEvent, BillingState> {
  final AppRepository appRepo;

  BillBloc({required this.appRepo})
      : super(const BillingState()) {
    on<BillSaveEvent>(_onBillSave);
  }

  _onBillSave(BillSaveEvent e, Emitter<BillingState> emitter) async {
    // emitter(state.copyWith(state: ProcessingState.pending));
    // var d = Decimal.parse(state.amount!);
    // var r = d * Decimal.fromInt(100);
    // var eLatest =  Expenditure.latest(
    //     state.bill, state.description, state.paymentType, state.billType!,
    //     r.toBigInt().toInt(), state.priority);
    // await appRepo.saveExpenditure(eLatest);
    // emitter(state.copyWith(state: ProcessingState.done));
  }
}
