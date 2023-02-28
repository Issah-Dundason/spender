import '../../model/bill.dart';

enum UpdateMethod { single, multiple }

abstract class BillEvent {
  const BillEvent();
}

class BillSaveEvent extends BillEvent {
  final Bill bill;

  const BillSaveEvent(this.bill);
}

class RecurrenceUpdateEvent extends BillEvent {
  final String instanceDate;
  final Bill update;
  final UpdateMethod updateMethod;

  RecurrenceUpdateEvent(this.instanceDate, this.update,
      [this.updateMethod = UpdateMethod.single]);
}

class NonRecurringUpdateEvent extends BillEvent {
  final Bill update;

  NonRecurringUpdateEvent(this.update);
}

class BillInitializationEvent extends BillEvent{}