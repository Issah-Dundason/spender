import 'package:equatable/equatable.dart';

import '../../model/expenditure.dart';
import '../../service/database.dart';

class HomeState extends Equatable {
  final Financials? currentFinancials;
  final List<MonthSpending> monthExpenditures;
  final List<Expenditure> transactionsToday;
  final int? firstEverRecordYear;
  final int analysisYear;

  const HomeState(
      {this.currentFinancials,
      required this.analysisYear,
      this.firstEverRecordYear,
      this.monthExpenditures = const [],
      this.transactionsToday = const []});

  HomeState copyWith(
      {Financials? financials,
      int? firstEverRecordYear,
      int? analysisYear,
      List<MonthSpending>? monthSpending,
      List<Expenditure>? transactions}) {
    return HomeState(
        analysisYear: analysisYear ?? this.analysisYear,
        firstEverRecordYear: firstEverRecordYear ?? this.firstEverRecordYear,
        currentFinancials: financials ?? currentFinancials,
        monthExpenditures: monthSpending ?? monthExpenditures,
        transactionsToday: transactions ?? transactionsToday);
  }

  @override
  List<Object?> get props => [currentFinancials, monthExpenditures];
}
