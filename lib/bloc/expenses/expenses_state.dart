import 'package:equatable/equatable.dart';

import '../../model/expenditure.dart';

class ExpensesState extends Equatable {
  final List<Expenditure> transactions;
  final DateTime selectedDate;
  final int? yearOfFirstInsert;
  final bool initialized;

  const ExpensesState(
      {this.transactions = const [],
      required this.selectedDate,
      this.initialized = false,
      this.yearOfFirstInsert});

  ExpensesState copyWith(
      {List<Expenditure>? transactions,
      DateTime? selectedDate,
      bool? initialized,
      int? yearOfFirstInsert}) {
    return ExpensesState(
        yearOfFirstInsert: yearOfFirstInsert ?? this.yearOfFirstInsert,
        initialized: initialized ?? this.initialized,
        selectedDate: selectedDate ?? this.selectedDate,
        transactions: transactions ?? this.transactions);
  }

  @override
  List<Object?> get props =>
      [transactions, selectedDate, yearOfFirstInsert, initialized];
}
