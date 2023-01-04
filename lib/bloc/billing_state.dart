import 'package:equatable/equatable.dart';

import '../model/bill_type.dart';
import '../model/expenditure.dart';

class BillingState extends Equatable {
  final BillType? billType;
  final String bill;
  final String? description;
  final PaymentType paymentType;
  final Priority priority;
  final String? amount;
  final List<BillType> billTypes;

  const BillingState({this.billTypes = const [],
    this.billType,
    this.bill = '',
    this.description,
    required this.paymentType,
    required this.priority,
    this.amount});

  BillingState copyWith({BillType? billType,
    String? bill,
    String? description,
    PaymentType? paymentType,
    Priority? priority, String? amount, List<BillType>? billTypes}) {
    return BillingState(
        bill: bill ?? this.bill,
        description: description ?? this.description,
        billType: billType ?? this.billType,
        billTypes: billTypes ?? this.billTypes,
        amount: amount ?? this.amount,
        paymentType: paymentType ?? this.paymentType,
        priority: priority ?? this.priority);
  }

  @override
  List<Object?> get props =>
      [billType, bill, description, paymentType, priority, amount];
}
