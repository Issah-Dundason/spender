import 'package:equatable/equatable.dart';

import '../model/model.dart';
import '../service/database.dart';

class AppState extends Equatable {
  final Financials? currentFinancials;
  final List<ProductType> productTypes;

  const AppState({this.currentFinancials, this.productTypes = const []});

  AppState copyWith({Financials? financials, List<ProductType>? productTypes}) {
    return AppState(
        currentFinancials: financials ?? currentFinancials,
        productTypes: productTypes ?? this.productTypes);
  }

  @override
  List<Object?> get props => [currentFinancials];
}

enum HomeTab { home, expenses, bill }

class HomeState extends Equatable {
  final HomeTab previous;
  final HomeTab current;

  const HomeState({this.previous = HomeTab.home, this.current = HomeTab.home});

  copyWith({HomeTab? previous, HomeTab? current}) {
    return HomeState(
        previous: previous ?? this.previous, current: current ?? this.current);
  }

  @override
  List<Object?> get props => [previous, current];
}
