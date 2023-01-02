import 'package:equatable/equatable.dart';

import '../model/product_type.dart';
import '../service/database.dart';

class HomeState extends Equatable {
  final Financials? currentFinancials;
  final List<MonthSpending> monthExpenditures;

  const HomeState({this.currentFinancials, this.monthExpenditures = const []});

  HomeState copyWith({Financials? financials, List<ProductType>? productTypes}) {
    return HomeState(
        currentFinancials: financials ?? currentFinancials,
        );
  }

  @override
  List<Object?> get props => [currentFinancials];
}