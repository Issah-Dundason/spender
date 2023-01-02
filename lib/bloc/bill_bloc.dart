import 'package:bloc/bloc.dart';
import 'package:spender/bloc/billing_event.dart';

import '../model/expenditure.dart';
import '../repository/expenditure_repo.dart';
import 'billing_state.dart';

class BillBloc extends Bloc<BillEvent, BillingState> {
  final AppRepository appRepo;

  BillBloc({required this.appRepo})
      : super(const BillingState(
      paymentType: PaymentType.cash, priority: Priority.want)) {
    on<BillInitializationEvent>(_onInitialize);
  }

  _onInitialize(e, Emitter<BillingState> emitter) async {
    var records = await appRepo.getBillTypes();
    emitter(state.copyWith(billTypes: records));
  }
}