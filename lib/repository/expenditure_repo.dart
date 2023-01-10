import 'package:spender/model/expenditure.dart';
import 'package:spender/service/database.dart';

import '../model/bill_type.dart';
import '../model/budget.dart';

class AppRepository {
  final DatabaseClient _dbClient;

  AppRepository(this._dbClient);

  Future<bool> budgetExist(String yearMonth) {
    return _dbClient.budgetExists(yearMonth);
  }

  Future updateBudget(Budget budget) {
    return _dbClient.updateBudget(budget);
  }

  Future saveBudget(Budget budget) {
    return _dbClient.saveBudget(budget);
  }

  Future<Budget?> getBudget(String yearMonth) {
    return _dbClient.getBudget(yearMonth);
  }

  Future<List<Budget>> getBudgetsForYear(String year) {
    return _dbClient.getBudgets(year);
  }

  Future<int?> getYearOfFirstBudget() {
    return _dbClient.getYearOfFirstBudget();
  }

  Future<bool> didTransactionsOnDay(String day) {
    return _dbClient.didTransactionOccurOnDay(day);
  }

  Future<Financials?> getFinancials(String date) {
    return _dbClient.getFinancials(date);
  }

  Future<List<BillType>> getBillTypes() {
    return _dbClient.getProductTypes();
  }

  Future<List<MonthSpending>> getAmountSpentEachMonth(String year) {
    return _dbClient.getAmountSpentEachMonth(year);
  }

  Future<List<Expenditure>> getExpenditureAt(String date, int limit) {
    return _dbClient.getExpenditureAtWithLimit(date, limit);
  }

  Future updateExpenditure(Expenditure expenditure) {
    return _dbClient.updateExpenditure(expenditure);
  }

  Future<List<PieData>> getPieData(String format, String date) {
    return _dbClient.getPieData(format, date);
  }


  Future deleteRepository(int id) {
    return _dbClient.deleteExpenditure(id);
  }

  Future<List<Expenditure>> getAllExpenditure(String date) {
    return _dbClient.getExpenditureByDate(date);
  }

  Future<int?> getYearOfFirstInsert() {
    return _dbClient.getYearOfFirstInsert();
  }

  Future saveExpenditure(Expenditure expenditure) {
    return _dbClient.saveExpenditure(expenditure.toJson());
  }
}
