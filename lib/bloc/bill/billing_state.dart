import 'package:equatable/equatable.dart';

import '../../model/bill.dart';
import '../../model/bill_type.dart';

enum ProcessingState { none, done, pending }

abstract class IBillingState extends Equatable {
  const IBillingState();

  @override
  List<Object?> get props => [];
}

class InitialBillingState extends IBillingState {
  const InitialBillingState();
}

class BillUpdateState extends IBillingState {
  final Bill bill;

  const BillUpdateState(this.bill);

  @override
  List<Object?> get props => [bill];
}

class BillTypesFetchedState extends IBillingState {
  final List<BillType> billTypes;

  const BillTypesFetchedState(this.billTypes);
}

class BillSavingState extends IBillingState {
  const BillSavingState();
}

class BillSavedState extends IBillingState {
  const BillSavedState();
}

class BillUpdatedState extends IBillingState {
  const BillUpdatedState();
}