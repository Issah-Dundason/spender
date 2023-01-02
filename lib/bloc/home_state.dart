import 'package:equatable/equatable.dart';

import '../model/product_type.dart';
import '../service/database.dart';

class HomeState extends Equatable {
  final Financials? currentFinancials;
  final List<ProductType> productTypes;

  const HomeState({this.currentFinancials, this.productTypes = const []});

  HomeState copyWith({Financials? financials, List<ProductType>? productTypes}) {
    return HomeState(
        currentFinancials: financials ?? currentFinancials,
        productTypes: productTypes ?? this.productTypes);
  }

  @override
  List<Object?> get props => [currentFinancials];
}