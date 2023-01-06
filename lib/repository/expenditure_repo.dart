import 'package:spender/model/expenditure.dart';
import 'package:spender/service/database.dart';

import '../model/bill_type.dart';
import '../model/budget.dart';

class AppRepository {
  late DatabaseClient dbClient;

  AppRepository(this.dbClient);

  Future<bool> budgetExist(String yearMonth) {
    return dbClient.budgetExists(yearMonth);
  }

  Future updateBudget(Budget budget) {
    return dbClient.updateBudget(budget);
  }

  Future saveBudget(Budget budget) {
    return dbClient.saveBudget(budget);
  }

  Future<Budget?> getBudget(String yearMonth) {
    return dbClient.getBudget(yearMonth);
  }

  Future<List<Budget>> getBudgetsForYear(String year) {
    return dbClient.getBudgets(year);
  }

  Future<int?> getYearOfFirstBudget() {
    return dbClient.getYearOfFirstBudget();
  }

  Future<Financials?> getFinancials(String date) {
    return dbClient.getFinancials(date);
  }

  Future<List<BillType>> getBillTypes() {
    return dbClient.getProductTypes();
  }

  Future<List<MonthSpending>> getAmountSpentEachMonth(String year) {
    return dbClient.getAmountSpentEachMonth(year);
  }

  Future<List<Expenditure>> getExpenditureAt(String date, int limit) {
    return dbClient.getExpenditureAtWithLimit(date, limit);
  }

  Future<int?> getYearOfFirstInsert() {
    return dbClient.getYearOfFirstInsert();
  }

  Future saveExpenditure(Expenditure expenditure) {
    return dbClient.saveExpenditure(expenditure.toJson());
  }
}
