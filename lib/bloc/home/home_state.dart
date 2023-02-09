import 'package:equatable/equatable.dart';

import '../../model/bill.dart';
import '../../service/database.dart';

enum DataLoading { none, pending, error, done }

class HomeState extends Equatable {
  final Financials? currentFinancials;
  final List<MonthSpending> monthExpenditures;
  final List<Bill> transactionsToday;
  final int? firstEverRecordYear;
  final int analysisYear;
  final DataLoading loadingState;

  const HomeState(
      {this.currentFinancials,
      required this.analysisYear,
      this.firstEverRecordYear,
      this.loadingState = DataLoading.none,
      this.monthExpenditures = const [],
      this.transactionsToday = const []});

  HomeState copyWith(
      {Financials? financials,
      int? firstEverRecordYear,
      int? analysisYear,
      DataLoading? loadingState,
      List<MonthSpending>? monthSpending,
      List<Bill>? transactions}) {
    return HomeState(
        analysisYear: analysisYear ?? this.analysisYear,
        firstEverRecordYear: firstEverRecordYear ?? this.firstEverRecordYear,
        loadingState: loadingState ?? this.loadingState,
        currentFinancials: financials ?? currentFinancials,
        monthExpenditures: monthSpending ?? monthExpenditures,
        transactionsToday: transactions ?? transactionsToday);
  }

  @override
  List<Object?> get props => [
        currentFinancials,
        monthExpenditures,
        transactionsToday,
        analysisYear,
        loadingState
      ];
}
