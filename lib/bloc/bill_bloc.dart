import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
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
    on<BillTitleChangeEvent>(_onBillTitleChange);
    on<BillTypeChangeEvent>(_onBillTypeChange);
    on<BillAmountChangeEvent>(_onBillAmount);
    on<BillPaymentTypeEvent>(_onPaymentTypeChange);
    on<BillDescriptionEvent>(_onDescriptionChange);
    on<BillPriorityChangeEvent>(_onPriorityChange);
    on<BillSaveEvent>(_onBillSave);
  }

  void _onInitialize(BillEvent e, Emitter<BillingState> emitter) async {
    var records = await appRepo.getBillTypes();
    emitter(state.copyWith(billTypes: records));
  }

  _onBillTitleChange(BillTitleChangeEvent e, Emitter<BillingState> emitter) {
    var title = e.title;
    emitter(state.copyWith(bill: title));
  }

  _onBillTypeChange(BillTypeChangeEvent e, Emitter<BillingState> emitter) {
    var type = e.productType;
    emitter(state.copyWith(billType: type));
  }

  _onBillAmount(BillAmountChangeEvent e, Emitter<BillingState> emitter) {
    var amount = e.amount;
    emitter(state.copyWith(amount: amount));
  }

  _onPaymentTypeChange(BillPaymentTypeEvent e, Emitter<BillingState> emitter) {
    var paymentType = e.paymentType;
    emitter(state.copyWith(paymentType: paymentType));
  }

  _onDescriptionChange(BillDescriptionEvent e, Emitter<BillingState> emitter) {
    var desc = e.description;
    emitter(state.copyWith(description: desc));
  }

  _onPriorityChange(BillPriorityChangeEvent e, Emitter<BillingState> emitter) {
    var priority = e.priority;
    emitter(state.copyWith(priority: priority));
  }

  _onBillSave(BillSaveEvent e, Emitter<BillingState> emitter) async {
    emitter(state.copyWith(state: ProcessingState.pending));
    var d = Decimal.parse(state.amount!);
    var r = d * Decimal.fromInt(100);
    var eLatest =  Expenditure.latest(
        state.bill, state.description, state.paymentType, state.billType!,
        r.toBigInt().toInt(), state.priority);
    await appRepo.saveExpenditure(eLatest);
    emitter(state.copyWith(state: ProcessingState.done));
  }
}
