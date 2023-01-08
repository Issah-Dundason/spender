import 'package:equatable/equatable.dart';

import '../../model/expenditure.dart';

class ExpensesState extends Equatable {
  final List<Expenditure> transactions;
  final DateTime selectedDate;

  const ExpensesState(
      {this.transactions = const [], required this.selectedDate});

  @override
  List<Object?> get props => [transactions, selectedDate];
}
