import '../../model/expenditure.dart';

abstract class BillEvent {
  const BillEvent();
}

class BillSaveEvent extends BillEvent {
  final Expenditure expenditure;

  const BillSaveEvent(this.expenditure);
}

class BillUpdateEvent extends BillEvent {
  final Expenditure expenditure;

  const BillUpdateEvent(this.expenditure);
}
