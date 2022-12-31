import 'package:spender/service/database.dart';

import '../model/model.dart';


class AppRepository {
  late DatabaseClient dbClient;

  Future<Budget?> getBudget(String date) {
    return dbClient.getBudget(date);
  }

}