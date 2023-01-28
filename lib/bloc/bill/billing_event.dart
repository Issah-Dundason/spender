import '../../model/bill.dart';

abstract class BillEvent {
  const BillEvent();
}

class BillSaveEvent extends BillEvent {
  final Bill expenditure;

  const BillSaveEvent(this.expenditure);
}

class BillUpdateEvent extends BillEvent {
  final Bill expenditure;

  const BillUpdateEvent(this.expenditure);
}
