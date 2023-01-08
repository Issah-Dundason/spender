import 'package:equatable/equatable.dart';

import '../../model/expenditure.dart';

class ExpensesState extends Equatable {
  final List<Expenditure> transactions;
  final DateTime selectedDate;
  final int? yearOfFirstInsert;

  const ExpensesState(
      {this.transactions = const [],
      required this.selectedDate,
      this.yearOfFirstInsert = 2023});

  ExpensesState copyWith(
      {List<Expenditure>? transactions,
      DateTime? selectedDate,
      int? yearOfFirstInsert}) {
    return ExpensesState(
        yearOfFirstInsert: yearOfFirstInsert ?? this.yearOfFirstInsert,
        selectedDate: selectedDate ?? this.selectedDate,
        transactions: transactions ?? this.transactions);
  }

  @override
  List<Object?> get props => [transactions, selectedDate, yearOfFirstInsert];
}
