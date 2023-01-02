import 'package:spender/service/database.dart';

import '../model/budget.dart';
import '../model/product_type.dart';


class AppRepository {
  late DatabaseClient dbClient;

  AppRepository(this.dbClient);

  Future<Budget?> getBudget(String date) {
    return dbClient.getBudget(date);
  }

  Future<List<ProductType>> getBillTypes() {
    return dbClient.getProductTypes();
  }

}