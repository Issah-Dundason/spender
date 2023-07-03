import 'package:spender/model/bill.dart';
import 'package:spender/service/database.dart';

import '../model/bill_type.dart';
import '../model/budget.dart';

class AppRepository {
  final DatabaseClient _dbClient;

  AppRepository(this._dbClient);

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

  Future<FinancialData?> getFinancials(String date) {
    return _dbClient.getFinancials(date);
  }

  Future<List<BillType>> getBillTypes() {
    return _dbClient.getProductTypes();
  }

  Future<List<MonthSpending>> getAmountSpentEachMonth(String year) {
    return _dbClient.getAmountSpentEachMonth(year);
  }

  Future<List<Bill>> getBillAt(DateTime dateTime, int limit) {
    return _dbClient.getBillAtWithLimit(dateTime, limit);
  }

  Future updateBill(int id, Map<String, dynamic> expenditure) {
    return _dbClient.updateBill(id, expenditure);
  }

  Future<List<PieData>> getPieData(String format, String date) {
    return _dbClient.getPieData(format, date);
  }

  Future<List<PieData>> getOverallPieData() {
    return _dbClient.getOverallPieData();
  }

  Future deleteBill(int id) {
    return _dbClient.deleteBill(id);
  }

  Future<List<Bill>> getAllBills(String date) {
    return _dbClient.getBillByDate(date);
  }

  Future<int?> getYearOfFirstInsert() {
    return _dbClient.getYearOfFirstInsert();
  }

  Future saveBill(Bill expenditure) {
    return _dbClient.saveBill(expenditure.toNewBillJson());
  }

  Future<void> updateException(int exceptionId, Map<String, dynamic> json) async {
    await _dbClient.updateException(exceptionId, json);
  }

  Future<void> createException(Map<String, dynamic> json) async {
   await _dbClient.createException(json);
  }

  Future<void> deleteParentExceptionAfterDate(int parentId, String endDate)  async {
  await _dbClient.deleteParentExceptionAfterDate(parentId, endDate);
  }

  Future<void> deleteAllExceptionsForParent(int i) async {
    await _dbClient.deleteAllExceptionsForParent(i);
  }

  Future<void> deleteGenerated(int exceptionId) async {
    await _dbClient.deleteGeneratedException(exceptionId);
  }

  Future<String> getLastEndDate(int parentId, String date) async {
    return await _dbClient.getLastEndDate(parentId, date);
  }
}
