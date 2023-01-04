
import '../model/bill_type.dart';
import '../model/expenditure.dart';

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


class BillTypeChangeEvent extends BillEvent {
  final BillType productType;

  BillTypeChangeEvent(this.productType);
}