import 'package:equatable/equatable.dart';

import '../model/expenditure.dart';
import '../model/product_type.dart';
import '../service/database.dart';

class HomeState extends Equatable {
  final Financials? currentFinancials;
  final List<MonthSpending> monthExpenditures;
  final List<Expenditure> transactionsToday;

  const HomeState({this.currentFinancials, this.monthExpenditures = const [], this.transactionsToday = const[]});

  HomeState copyWith(
      {Financials? financials, List<MonthSpending>? monthSpending, List<Expenditure>? transactions}) {
    return HomeState(
        currentFinancials: financials ?? currentFinancials,
        monthExpenditures: monthSpending ?? monthExpenditures,
    transactionsToday: transactions ?? transactionsToday);
  }

  @override
  List<Object?> get props => [currentFinancials, monthExpenditures];
}
