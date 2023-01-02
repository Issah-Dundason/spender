import 'package:equatable/equatable.dart';

import '../model/model.dart';
import '../service/database.dart';

class AppState extends Equatable {
  final Financials? currentFinancials;
  final List<ProductType> productTypes;

  const AppState({this.currentFinancials, this.productTypes = const []});

  AppState copyWith({Financials? financials, List<ProductType>? productTypes}) {
    return AppState(
        currentFinancials: financials ?? currentFinancials,
        productTypes: productTypes ?? this.productTypes);
  }

  @override
  List<Object?> get props => [currentFinancials];
}

enum HomeTab { home, expenses, bill }

class HomeState extends Equatable {
  final HomeTab previous;
  final HomeTab current;

  const HomeState({this.previous = HomeTab.home, this.current = HomeTab.home});

  copyWith({HomeTab? previous, HomeTab? current}) {
    return HomeState(
        previous: previous ?? this.previous, current: current ?? this.current);
  }

  @override
  List<Object?> get props => [previous, current];
}

class BillingState extends Equatable {
  final ProductType? billType;
  final String bill;
  final String? description;
  final PaymentType paymentType;
  final Priority priority;
  final String? amount;
  final List<ProductType> billTypes;

  const BillingState({this.billTypes = const [],
    this.billType,
    this.bill = '',
    this.description,
    required this.paymentType,
    required this.priority,
    this.amount});

  BillingState copyWith({ProductType? billType,
    String? bill,
    String? description,
    PaymentType? paymentType,
    Priority? priority, String? amount, List<ProductType>? billTypes}) {
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
