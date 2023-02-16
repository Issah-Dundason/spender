import '../../model/bill.dart';

enum UpdateMethod { single, multiple }

abstract class BillEvent {
  const BillEvent();
}

class BillSaveEvent extends BillEvent {
  final Bill expenditure;

  const BillSaveEvent(this.expenditure);
}

class RecurrenceUpdateEvent extends BillEvent {
  final String instanceDate;
  final Bill update;
  final UpdateMethod updateMethod;

  const RecurrenceUpdateEvent(this.instanceDate, this.update,
      {this.updateMethod = UpdateMethod.single});
}

class NonRecurringUpdateEvent extends BillEvent {
  final Bill update;

  NonRecurringUpdateEvent(this.update);
}


class BillUpdateEvent extends BillEvent {
  final String oldPaymentDate;
  final Bill update;
  final UpdateMethod method;

  BillUpdateEvent(this.oldPaymentDate, this.update, [this.method = UpdateMethod.single]);
}