import 'package:equatable/equatable.dart';

import '../../model/bill.dart';

abstract class IExpensesState extends Equatable {
  const IExpensesState();

  @override
  List<Object?> get props => [];
}

class ExpensesDeletingState extends IExpensesState {
  const ExpensesDeletingState();
}

class ExpensesDeletedState extends IExpensesState {
  const ExpensesDeletedState();
}

class ExpensesLoadingState extends IExpensesState {
  const ExpensesLoadingState();
}

class ExpensesSuccessfulState extends IExpensesState {
  final List<Bill> transactions;
  final DateTime selectedDate;
  final int? yearOfFirstInsert;

  const ExpensesSuccessfulState({
    this.transactions = const [],
    required this.selectedDate,
    this.yearOfFirstInsert,
  });

  ExpensesSuccessfulState copyWith({
    List<Bill>? transactions,
    DateTime? selectedDate,
    int? yearOfFirstInsert,
  }) {
    return ExpensesSuccessfulState(
      yearOfFirstInsert: yearOfFirstInsert ?? this.yearOfFirstInsert,
      selectedDate: selectedDate ?? this.selectedDate,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props {
    return [
      transactions,
      selectedDate,
      yearOfFirstInsert,
    ];
  }
}
