import 'package:equatable/equatable.dart';

import '../../model/bill.dart';

enum DeleteState { none, deleting, deleted }

class ExpensesState extends Equatable {
  final List<Bill> transactions;
  final DateTime selectedDate;
  final int? yearOfFirstInsert;
  final bool initialized;
  final DeleteState deleteState;

  const ExpensesState(
      {this.transactions = const [],
      required this.selectedDate,
      this.initialized = false,
      this.yearOfFirstInsert,
      this.deleteState = DeleteState.none});

  ExpensesState copyWith(
      {List<Bill>? transactions,
      DateTime? selectedDate,
      bool? initialized,
      DeleteState? deleteState,
      int? yearOfFirstInsert}) {
    return ExpensesState(
        yearOfFirstInsert: yearOfFirstInsert ?? this.yearOfFirstInsert,
        initialized: initialized ?? this.initialized,
        deleteState: deleteState ?? this.deleteState,
        selectedDate: selectedDate ?? this.selectedDate,
        transactions: transactions ?? this.transactions);
  }

  @override
  List<Object?> get props {
    return [
      transactions,
      selectedDate,
      yearOfFirstInsert,
      initialized,
      deleteState
    ];
  }
}
