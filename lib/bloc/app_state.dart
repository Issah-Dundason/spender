import 'package:equatable/equatable.dart';

import '../model/model.dart';
import '../service/database.dart';

class AppState extends Equatable {
  final Financials? currentFinancials;
  final List<ProductType> productTypes;

  const AppState({this.currentFinancials, this.productTypes = const []});

  AppState copyWith({Financials? financials, List<ProductType>? productTypes}) {
    return AppState(
      currentFinancials: financials ?? financials,
      productTypes: productTypes ?? this.productTypes
    );
  }

  @override
  List<Object?> get props => [currentFinancials];
}

enum HomeTabs { home, expenses, profile }
