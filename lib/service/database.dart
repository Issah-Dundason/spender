import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/bill_type.dart';
import '../model/budget.dart';
import '../model/bill.dart';
import 'queries.dart';

class DatabaseClient {
  static const int _version = 2;
  static const String _databaseName = "spender.app";

  late final Database _db;

  Future<DatabaseClient> init() async {
    await _openDatabase();
    return this;
  }

  Future _openDatabase() async {
    var dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase("${dir.path}/$_databaseName",
        version: _version, onCreate: _create);
  }

  Future _create(Database db, int i) async {
    await db.execute(Query.billTypeTable);
    await db.execute(Query.expenditureTable);
    await db.execute(Query.budgetTable);
    await db.execute(Query.expenditureExceptionTable);

    await db.insert("bill_type", {"name": "Food", "image": "food.svg"});
    await db.insert(
        "bill_type", {"name": "Clothing & beauty", "image": "clothing.svg"});
    await db
        .insert("bill_type", {"name": "Investment", "image": "investment.svg"});
    await db.insert("bill_type", {"name": "Health", "image": "medicine.svg"});
    await db.insert(
        "bill_type", {"name": "Electricity", "image": "electricity.svg"});
    await db.insert(
        "bill_type", {"name": "Transportation", "image": "transportation.svg"});
    await db.insert("bill_type", {"name": "Other", "image": "other.svg"});
  }

  Future<Financials?> getFinancials(String date) async {
    var result = await _db.rawQuery(
        Query.financialsQuery, [DateTime.now().toIso8601String(), date, date]);

    if (result.isEmpty) {
      return null;
    }

    return Financials.fromMap(result[0]);
  }

  Future saveBudget(Budget budget) async {
    await _db.insert("budget", budget.toMap());
  }

  Future saveExpenditure(Map<String, dynamic> map) async {
    await _db.insert("expenditure", map);
  }

  Future<List<Bill>> getBillAtWithLimit(DateTime dateTime, int limit) async {
    var date = DateFormat("yyyy-MM-dd").format(dateTime);
    var result = await _db.rawQuery(Query.getExpenditureWithLimitQuery(),
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
    var results = await _db.rawQuery(Query.didTransactionOccurQuery, [day]);
    return results.isNotEmpty;
  }

  Future deleteExpenditure(int id) async {
    await _db.delete("expenditure", where: "id = ?", whereArgs: [id]);
  }

  Future updateExpenditure(int id, Map<String, dynamic> expenditure) async {
    await _db
        .update("expenditure", expenditure, where: "id = ?", whereArgs: [id]);
  }

  Future<void> createException(Map<String, dynamic> json) async {
    await _db.insert('expenditure_exception', json);
  }

  Future<int?> getYearOfFirstBudget() async {
    var result =
        await _db.rawQuery('''SELECT CAST(strftime('%Y', date) as int) as year
           FROM budget ORDER BY date LIMIT 1''');
    if (result.isNotEmpty) return Sqflite.firstIntValue(result);
    return null;
  }

  Future<bool> budgetExists(String yearMonth) async {
    var records = await _db.query("budget",
        where: "strftime('%Y-%m', date) = ?", whereArgs: [yearMonth]);
    return records.length == 1;
  }

  Future updateBudget(Budget budget) async {
    await _db.update("budget", budget.toMap(),
        where: "id = ?", whereArgs: [budget.id]);
  }

  Future deleteBudget(Budget budget) async {
    await _db.delete("budget", where: "id = ?", whereArgs: [budget.id]);
  }

  Future<Budget?> getBudget(String yearMonth) async {
    var result = await _db.query("budget",
        where: "strftime('%Y-%m', date) = ?", whereArgs: [yearMonth]);
    if (result.isEmpty) return null;
    return Budget.fromMap(result[0]);
  }

  Future<List<Budget>> getBudgets(String year) async {
    var result = await _db.query("budget",
        where: "strftime('%Y', date) = ?",
        orderBy: "date ASC",
        whereArgs: [year]);
    if (result.isEmpty) return [];
    return result.map((map) => Budget.fromMap(map)).toList();
  }

  Future<List<Bill>> getExpenditureByDate(String date) async {
    var result = await _db.rawQuery(Query.expenditureByDateQuery, [date]);

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
    var records = await _db.rawQuery(
        Query.pieQuery(format, date), [DateTime.now().toIso8601String()]);

    return records
        .map((record) =>
            PieData(record['amount'] as int, BillType.fromMap(record)))
        .toList();
  }

  Future<List<PieData>> getOverallPieData() async {
    var records = [];
    return records
        .map((record) =>
            PieData(record['amount'] as int, BillType.fromMap(record)))
        .toList();
  }

  Future<List<BillType>> getProductTypes() async {
    var result = await _db.query("bill_type");
    return result
        .map((record) => BillType(record["id"] as int, record["name"] as String,
            record["image"] as String))
        .toList();
  }

  Future<int?> getYearOfFirstInsert() async {
    var result = await _db.rawQuery(
        "SELECT payment_datetime as edate FROM expenditure ORDER BY payment_datetime ASC LIMIT 1");
    if (result.isEmpty) return null;
    var date = DateTime.parse(result[0]['edate'] as String);
    return date.year;
  }

  Future<List<MonthSpending>> getAmountSpentEachMonth(String year) async {
    String dateTime = DateTime.now().toIso8601String();
    var result =
        await _db.rawQuery(Query.getMonthSpendingQuery(), [dateTime, year]);
    return result
        .map((record) => MonthSpending(
            int.parse(record["month"] as String), record["amount"] as int))
        .toList();
  }

  Future<void> updateException(
      int exceptionId, Map<String, dynamic> json) async {
    await _db.update('expenditure_exception', json,
        where: 'id = ?', whereArgs: [exceptionId]);
  }

  void deleteParentExceptionAfterDate(int parentId, String endDate) async {
    await _db.update('expenditure', {Bill.columnEndDate: endDate},
        where: 'id = ?', whereArgs: [parentId]);
    await _db.delete('expenditure_exception',
        where:
            '${Bill.columnExceptionParentId} = ? AND datetime(${Bill.columnPaymentDate}) > datetime(?)',
        whereArgs: [parentId, endDate]);
  }

  Future<void> deleteAllExceptionsForParent(int parentId) async {
    await _db.delete('expenditure_exception',
        where: '${Bill.columnExceptionParentId} = ?', whereArgs: [parentId]);
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
