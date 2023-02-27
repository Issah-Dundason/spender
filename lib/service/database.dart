import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/bill_type.dart';
import '../model/budget.dart';
import '../model/bill.dart';
import 'queries.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseClient {
  static const int _version = 2;
  static const String _databaseName = "spender.app";

  @protected
  late final Database db;

  Future<DatabaseClient> init() async {
    await _openDatabase();
    return this;
  }

  Future _openDatabase() async {
    var databaseFactory = databaseFactoryFfi;
    var dir = await getApplicationDocumentsDirectory();
    db = await databaseFactory.openDatabase("${dir.path}/$_databaseName",
        options: OpenDatabaseOptions(onCreate: _create, version: _version));
  }

  Future _create(Database db, int i) async {
    await db.execute(Query.billTypeTable);
    await db.execute(Query.expenditureTable);
    await db.execute(Query.budgetTable);
    await db.execute(Query.expenditureExceptionTable);

    await db.insert(BillType.tableName, {"name": "Food", "image": "food.svg"});
    await db.insert(BillType.tableName,
        {"name": "Clothing & beauty", "image": "clothing.svg"});
    await db.insert(
        BillType.tableName, {"name": "Investment", "image": "investment.svg"});
    await db.insert(
        BillType.tableName, {"name": "Health", "image": "medicine.svg"});
    await db.insert(BillType.tableName,
        {"name": "Electricity", "image": "electricity.svg"});
    await db.insert(BillType.tableName,
        {"name": "Transportation", "image": "transportation.svg"});
    await db
        .insert(BillType.tableName, {"name": "Other", "image": "other.svg"});
  }

  Future<Financials?> getFinancials(String date) async {
    var result = await db.rawQuery(
        Query.financialsQuery, [DateTime.now().toIso8601String(), date, date]);

    if (result.isEmpty) {
      return null;
    }

    return Financials.fromMap(result[0]);
  }

  Future saveBudget(Budget budget) async {
    await db.insert("budget", budget.toMap());
  }

  Future saveBill(Map<String, dynamic> map) async {
    await db.insert(Bill.tableName, map);
  }

  Future<List<Bill>> getBillAtWithLimit(DateTime dateTime, int limit) async {
    var date = DateFormat("yyyy-MM-dd").format(dateTime);
    var result = await db.rawQuery(Query.getExpenditureWithLimitQuery(),
        [date, dateTime.toIso8601String(), limit]);
    return result.map((record) {
      Map<String, dynamic> modified = Map.from(record);
      modified["type"] = {
        "bill_type": record["bill_type"],
        "bill_name": record["bill_name"],
        "bill_image": record["bill_image"]
      };
      return Bill.fromJson(modified);
    }).toList();
  }

  Future<bool> didTransactionOccurOnDay(String day) async {
    var results = await db.rawQuery(Query.didTransactionOccurQuery, [day]);
    return results.isNotEmpty;
  }

  Future deleteBill(int id) async {
    await db.delete(Bill.tableName, where: "id = ?", whereArgs: [id]);
  }

  Future updateBill(int id, Map<String, dynamic> expenditure) async {
    await db
        .update(Bill.tableName, expenditure, where: "id = ?", whereArgs: [id]);
  }

  Future<void> createException(Map<String, dynamic> json) async {
    await db.insert('expenditure_exception', json);
  }

  Future<int?> getYearOfFirstBudget() async {
    var result =
        await db.rawQuery('''SELECT CAST(strftime('%Y', date) as int) as year
           FROM budget ORDER BY date LIMIT 1''');
    if (result.isNotEmpty) return Sqflite.firstIntValue(result);
    return null;
  }

  Future<bool> budgetExists(String yearMonth) async {
    var records = await db.query("budget",
        where: "strftime('%Y-%m', date) = ?", whereArgs: [yearMonth]);
    return records.length == 1;
  }

  Future updateBudget(Budget budget) async {
    await db.update("budget", budget.toMap(),
        where: "id = ?", whereArgs: [budget.id]);
  }

  Future deleteBudget(Budget budget) async {
    await db.delete("budget", where: "id = ?", whereArgs: [budget.id]);
  }

  Future<Budget?> getBudget(String yearMonth) async {
    var result = await db.query("budget",
        where: "strftime('%Y-%m', date) = ?", whereArgs: [yearMonth]);
    if (result.isEmpty) return null;
    return Budget.fromMap(result[0]);
  }

  Future<List<Budget>> getBudgets(String year) async {
    var result = await db.query("budget",
        where: "strftime('%Y', date) = ?",
        orderBy: "date ASC",
        whereArgs: [year]);
    if (result.isEmpty) return [];
    return result.map((map) => Budget.fromMap(map)).toList();
  }

  Future<List<Bill>> getBillByDate(String date) async {
    var result = await db.rawQuery(Query.expenditureByDateQuery, [date]);

    return result.map((record) {
      Map<String, dynamic> modified = Map.from(record);
      modified["type"] = {
        "bill_type": record["bill_type"],
        "bill_name": record["bill_name"],
        "bill_image": record["bill_image"]
      };
      return Bill.fromJson(modified);
    }).toList();
  }

  Future<List<PieData>> getPieData(String format, String date) async {
    var records = await db.rawQuery(
        Query.pieQuery(format, date), [DateTime.now().toIso8601String()]);

    return records
        .map((record) =>
            PieData(record['amount'] as int, BillType.fromMap(record)))
        .toList();
  }

  Future<List<PieData>> getOverallPieData() async {
    var records = await db.rawQuery(
        Query.overallPieDataQuery, [DateTime.now().toIso8601String()]);
    return records
        .map((record) =>
            PieData(record['amount'] as int, BillType.fromMap(record)))
        .toList();
  }

  Future<List<BillType>> getProductTypes() async {
    var result = await db.query("bill_type");
    return result
        .map((record) => BillType(record["id"] as int, record["name"] as String,
            record["image"] as String))
        .toList();
  }

  Future<int?> getYearOfFirstInsert() async {
    var result = await db.rawQuery(
        "SELECT payment_datetime as edate FROM expenditure ORDER BY payment_datetime ASC LIMIT 1");
    if (result.isEmpty) return null;
    var date = DateTime.parse(result[0]['edate'] as String);
    return date.year;
  }

  Future<List<MonthSpending>> getAmountSpentEachMonth(String year) async {
    String dateTime = DateTime.now().toIso8601String();
    var result =
        await db.rawQuery(Query.getMonthSpendingQuery(), [dateTime, year]);
    return result
        .map((record) => MonthSpending(
            int.parse(record["month"] as String), record["amount"] as int))
        .toList();
  }

  Future<void> updateException(
      int exceptionId, Map<String, dynamic> json) async {
    await db.update('expenditure_exception', json,
        where: 'id = ?', whereArgs: [exceptionId]);
  }

  Future<void> deleteParentExceptionAfterDate(
      int parentId, String endDate) async {
    await db.update('expenditure', {Bill.columnEndDate: endDate},
        where: 'id = ?', whereArgs: [parentId]);
    await db.delete(
      'expenditure_exception',
      where:
          '${Bill.columnExceptionParentId} = ? AND datetime(${Bill.columnPaymentDate}) > datetime(?)',
      whereArgs: [parentId, endDate],
    );
  }

  Future<void> deleteAllExceptionsForParent(int parentId) async {
    await db.delete(
      'expenditure_exception',
      where: '${Bill.columnExceptionParentId} = ?',
      whereArgs: [parentId],
    );
  }

  Future<void> deleteGeneratedException(int exceptionId) async {
    await db.update(
      'expenditure_exception',
      {'deleted': 1},
      where: "id = ?",
      whereArgs: [exceptionId],
    );
  }

  Future<String> getLastEndDate(int parentId, String date) async {
    var record = await db.rawQuery(Query.lastEndDate, [
      date,
      parentId,
      parentId,
    ]);
    if (record.isEmpty) throw UnavailableException();
    return record.first['payment_datetime'] as String;
  }
}

class PieData extends Equatable {
  final int amount;
  final BillType billType;

  const PieData(this.amount, this.billType);

  @override
  List<Object?> get props => [amount, billType];
}

class Financials extends Equatable {
  final int budget;
  final int balance;
  final int amountSpent;

  const Financials(this.budget, this.balance, this.amountSpent);

  Financials.fromMap(Map<String, dynamic> map)
      : budget = map["budget"],
        balance = map["balance"],
        amountSpent = map["amount_spent"];

  @override
  List<Object?> get props => [budget, balance, amountSpent];
}

class MonthSpending extends Equatable {
  final int month;
  final int amount;

  const MonthSpending(this.month, this.amount);

  @override
  String toString() {
    return '{month: $month, amount: $amount}';
  }

  @override
  List<Object?> get props => [amount, month];
}

class UnavailableException implements Exception {}
