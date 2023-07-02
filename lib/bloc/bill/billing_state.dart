import 'package:equatable/equatable.dart';
import '../../model/bill.dart';
import '../../model/bill_type.dart';

abstract class IBillingState extends Equatable {
  final List<BillType> billTypes;

  const IBillingState(this.billTypes);

  @override
  List<Object?> get props => [billTypes];
}

class IdleBillingState extends IBillingState {
  const IdleBillingState(super.billTypes);
}

class BillUpdateState extends IBillingState {
  final Bill bill;

  const BillUpdateState(this.bill, super.billTypes);

  @override
  List<Object?> get props => [bill, billTypes];
}

class BillSavingState extends IBillingState {
  const BillSavingState(super.billTypes);
}

class BillSavedState extends IBillingState {
  const BillSavedState(super.billTypes);
}

class BillUpdatedState extends IBillingState {
  const BillUpdatedState(super.billTypes);
}

class BillCreateState extends IBillingState {
  const BillCreateState(super.billTypes);
}