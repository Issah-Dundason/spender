import '../../model/bill.dart';

enum UpdateMethod { single, multiple }

abstract class IBillEvent {
  const IBillEvent();
}

class BillSaveEvent extends IBillEvent {
  final Bill bill;

  const BillSaveEvent(this.bill);
}

class RecurringBillUpdateEvent extends IBillEvent {
  final String instanceDate;
  final Bill update;
  final UpdateMethod updateMethod;

  RecurringBillUpdateEvent(
    this.instanceDate,
    this.update, [
    this.updateMethod = UpdateMethod.single,
  ]);
}

class NonRecurringBillUpdateEvent extends IBillEvent {
  final Bill update;

  const NonRecurringBillUpdateEvent(this.update);
}

class BillTypesFetchEvent extends IBillEvent {
  const BillTypesFetchEvent();
}

class BillCreationEvent extends IBillEvent {
  const BillCreationEvent();
}

class BillUpdateEvent extends IBillEvent {
  final Bill bill;

  const BillUpdateEvent(this.bill);
}