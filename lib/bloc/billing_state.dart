import 'package:equatable/equatable.dart';

import '../model/bill_type.dart';
import '../model/expenditure.dart';

enum ProcessingState {none, done, pending}

class BillingState extends Equatable {
  final BillType? billType;
  final String bill;
  final String? description;
  final PaymentType paymentType;
  final Priority priority;
  final String? amount;
  final List<BillType> billTypes;
  final ProcessingState processingState;

  const BillingState({this.billTypes = const [],
    this.billType,
    this.bill = '',
    this.description,
    this.processingState = ProcessingState.none,
    required this.paymentType,
    required this.priority,
    this.amount});

  BillingState copyWith({BillType? billType,
    String? bill,
    String? description,
    PaymentType? paymentType,
    ProcessingState? state,
    Priority? priority, String? amount, List<BillType>? billTypes}) {
    return BillingState(
        bill: bill ?? this.bill,
        processingState: state ?? processingState,
        description: description ?? this.description,
        billType: billType ?? this.billType,
        billTypes: billTypes ?? this.billTypes,
        amount: amount ?? this.amount,
        paymentType: paymentType ?? this.paymentType,
        priority: priority ?? this.priority);
  }

  @override
  List<Object?> get props =>
      [billType, bill, description, paymentType, priority, amount, processingState];
}
