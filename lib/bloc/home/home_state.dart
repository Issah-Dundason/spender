import 'package:equatable/equatable.dart';

import '../../model/bill.dart';
import '../../service/database.dart';

abstract class IHomeState extends Equatable {
  const IHomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoadingState extends IHomeState {
  const HomeLoadingState();
}

class HomeSuccessFetchState extends IHomeState {
  final FinancialData? currentFinancials;
  final List<MonthSpending> monthExpenditures;
  final List<Bill> transactionsToday;
  final int? firstEverRecordYear;

  const HomeSuccessFetchState(
      {this.currentFinancials,
      this.firstEverRecordYear,
      this.monthExpenditures = const [],
      this.transactionsToday = const []});

  HomeSuccessFetchState copyWith(
      {FinancialData? financials,
      int? firstEverRecordYear,
      int? analysisYear,
      List<MonthSpending>? monthSpending,
      List<Bill>? transactions}) {
    return HomeSuccessFetchState(
        firstEverRecordYear: firstEverRecordYear ?? this.firstEverRecordYear,
        currentFinancials: financials ?? currentFinancials,
        monthExpenditures: monthSpending ?? monthExpenditures,
        transactionsToday: transactions ?? transactionsToday);
  }

  @override
  List<Object?> get props => [
        currentFinancials,
        monthExpenditures,
        transactionsToday,
      ];
}
