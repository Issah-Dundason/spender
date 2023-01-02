import 'package:equatable/equatable.dart';
import 'package:spender/model/model.dart';

abstract class AppEvent{
  const AppEvent();
}

class AppStart extends AppEvent {
  const AppStart();
}


abstract class BillEvent {
  const BillEvent();
}

class BillInitializationEvent extends BillEvent {}

class BillTitleChangeEvent extends BillEvent {
  final String title;

  BillTitleChangeEvent(this.title);
}

class BillAmountChangeEvent extends BillEvent {
  final String amount;

  BillAmountChangeEvent(this.amount);
}

class BillDescriptionEvent extends BillEvent {
  final String description;

  BillDescriptionEvent(this.description);
}

class BillPaymentTypeEvent extends BillEvent {
  final PaymentType paymentType;

  BillPaymentTypeEvent(this.paymentType);
}

class BillPriorityChangeEvent extends BillEvent {
  final Priority priority;

  BillPriorityChangeEvent(this.priority);
}


class BillBillTypeChangeEvent extends BillEvent {
  final ProductType productType;

  BillBillTypeChangeEvent(this.productType);
}