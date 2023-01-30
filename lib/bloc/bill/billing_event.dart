import '../../model/bill.dart';

enum UpdateMethod { single, multiple }

abstract class BillEvent {
  const BillEvent();
}

class BillSaveEvent extends BillEvent {
  final Bill expenditure;

  const BillSaveEvent(this.expenditure);
}

class BillUpdateEvent extends BillEvent {
  final Bill expenditure;
  final UpdateMethod updateMethod;

  const BillUpdateEvent(
      {required this.expenditure, this.updateMethod = UpdateMethod.single});
}
