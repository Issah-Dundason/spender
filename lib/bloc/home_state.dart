import 'package:equatable/equatable.dart';

import '../model/product_type.dart';
import '../service/database.dart';

class HomeState extends Equatable {
  final Financials? currentFinancials;
  final List<MonthSpending> monthExpenditures;

  const HomeState({this.currentFinancials, this.monthExpenditures = const []});

  HomeState copyWith({Financials? financials, List<MonthSpending>? monthSpending}) {
    return HomeState(
        currentFinancials: financials ?? currentFinancials,
      monthExpenditures: monthSpending ?? monthExpenditures
        );
  }

  @override
  List<Object?> get props => [currentFinancials, monthExpenditures];
}