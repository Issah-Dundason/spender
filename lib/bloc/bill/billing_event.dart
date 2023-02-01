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
  final String? instanceDate;
  final Bill update;
  final UpdateMethod updateMethod;

  const BillUpdateEvent(this.instanceDate, this.update,
      {this.updateMethod = UpdateMethod.single});
}
