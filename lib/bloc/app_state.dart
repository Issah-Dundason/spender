

import 'package:equatable/equatable.dart';

import '../service/database.dart';

class AppState extends Equatable {
  final Financials? currentFinancials;

  const AppState(this.currentFinancials);

  AppState copyWith({Financials? financials}) {
    return AppState(financials ?? financials);
  }


  @override
  List<Object?> get props => [currentFinancials];
}

enum HomeTabs {
  home, expenses, profile
}