import 'package:equatable/equatable.dart';

import '../../model/bill_type.dart';

enum ProcessingState { none, done, pending }

class BillingState extends Equatable {
  final ProcessingState processingState;
  final List<BillType> billTypes;

  const BillingState({this.processingState = ProcessingState.none, this.billTypes = const []});

  copyWith({ProcessingState? processingState, List<BillType>? billTypes}) {
    var procState = processingState = processingState ?? this.processingState;
    var types = billTypes ?? this.billTypes;

    return BillingState(processingState: procState, billTypes: types);
  }

  @override
  List<Object?> get props => [processingState, processingState];
}

class PState extends BillingState {

}
