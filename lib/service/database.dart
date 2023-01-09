import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/bill_type.dart';
import '../model/budget.dart';
import '../model/expenditure.dart';

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

  Future<bool> didTransactionOccurOnDay(String day) async {
    var results = await _db.query("expenditure",
        where: "strftime('%Y-%m-%d', date) = ?", whereArgs: [day], limit: 1);
    return results.isNotEmpty;
  }

  Future deleteExpenditure(int id) async {
    await _db.delete("expenditure", where: "id = ?", whereArgs: [id]);
  }

  Future updateExpenditure(Expenditure expenditure) async {
    await _db.update("expenditure", expenditure.toJson(),
        where: "id = ?", whereArgs: [expenditure.id]);
  }

  Future saveBudget(Budget budget) async {
    await _db.insert("budget", budget.toMap());
  }

  Future<int?> getYearOfFirstBudget() async {
    var result = await _db.rawQuery(
        '''SELECT CAST(strftime('%Y', date) as int) as year 
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

  Future<Financials?> getFinancials(String date) async {
    var result = await _db.rawQuery('''
    SELECT b.amount as budget, 
          CASE 
            WHEN  b.amount - t.amount_spent   ISNULL THEN b.amount
            ELSE (b.amount - t.amount_spent) 
            END as balance,
          CASE
            WHEN t.amount_spent ISNULL THEN 0 
            ELSE t.amount_spent
            END as amount_spent  
    FROM budget b 
    LEFT JOIN 
    (SELECT SUM(price) as amount_spent, 
            strftime('%Y-%m', date) as date 
    FROM expenditure 
    GROUP BY 2
    HAVING strftime('%Y-%m', date) = ?) t 
    on t.date = strftime('%Y-%m', b.date) 
    WHERE strftime('%Y-%m', b.date) = ?;
    ''', [date, date]);
    if (result.isEmpty) {
      return null;
    }

    return Financials.fromMap(result[0]);
  }

  ///date is a string of date formatted as yyyy-MM
  Future<List<Expenditure>> getByYearAndMonth(String date) async {
    var result = await _db.rawQuery('''
      SELECT e.id as eid, 
            e.bill AS ebill, 
            e.description as edesc, 
            e.payment_type as epay, 
            e.price as eprice, e.date as edate, 
            e.priority as epri, 
            p.id as pid, p.name as pname
      FROM expenditure e 
      JOIN bill_type p 
      ON e.bill_type_id = p.id WHERE strftime('%Y-%m', e.date) = ?;
    ''', [date]);
    return result.map((e) => Expenditure.fromMap(e)).toList();
  }

  Future<List<Expenditure>> getExpenditureByDate(String date) async {
    var result = await _db.rawQuery('''
      SELECT e.id as eid, 
            e.bill AS ebill, 
            e.description as edesc, 
            e.payment_type as epay, 
            e.price as eprice, e.date as edate, 
            e.priority as epri, 
            p.id as pid, p.name as pname
      FROM expenditure e 
      JOIN bill_type p 
      ON e.bill_type_id = p.id WHERE strftime('%Y-%m-%d', edate) = ? ORDER BY e.date DESC;
    ''', [date]);
    return result.map((e) => Expenditure.fromMap(e)).toList();
  }


  Future<List<BillType>> getProductTypes() async {
    var result = await _db.query("bill_type");
    return result
        .map((e) => BillType(e["id"] as int, e["name"] as String))
        .toList();
  }

  Future saveExpenditure(Map<String, dynamic> map) async {
    await _db.insert("expenditure", map);
  }

  Future<int?> getYearOfFirstInsert() async {
    var result = await _db.rawQuery(
        "SELECT CAST(strftime('%Y', date) as int) as year FROM expenditure ORDER BY date LIMIT 1");
    if (result.isNotEmpty) return Sqflite.firstIntValue(result);
    return null;
  }

  Future<List<Expenditure>> getExpenditureAtWithLimit(
      String date, int limit) async {
    var result = await _db.rawQuery('''
      SELECT e.id as eid, 
            e.bill AS ebill, 
            e.description as edesc, 
            e.payment_type as epay, 
            e.price as eprice, e.date as edate, 
            e.priority as epri, 
            p.id as pid, p.name as pname
      FROM expenditure e 
      JOIN bill_type p 
      ON e.bill_type_id = p.id WHERE strftime('%Y-%m-%d', edate) = ? ORDER BY e.date DESC LIMIT ?;
    ''', [date, limit]);
    return result.map((e) => Expenditure.fromMap(e)).toList();
  }

  Future<List<MonthSpending>> getAmountSpentEachMonth(String year) async {
    var result = await _db.rawQuery('''SELECT strftime('%m',date) as month, 
          SUM(price) as amount FROM expenditure GROUP BY 1 HAVING strftime('%Y',date) = ?
          ORDER BY strftime('%m',date) ASC
          ''', [year]);
    return result
        .map((q) =>
            MonthSpending(int.parse(q["month"] as String), q["amount"] as int))
        .toList();
  }

  Future _create(Database db, int i) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bill_type (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT  NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenditure (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        bill TEXT NOT NULL,
        description TEXT,
        payment_type INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        bill_type_id INTEGER,
        price INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (bill_type_id) REFERENCES bill_type(id)
      );
    ''');
    await db.execute('''
        CREATE TABLE IF NOT EXISTS budget (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          amount INTEGER NOT NULL
       );
    ''');
    await db.insert("bill_type", {"name": "Food"});
    await db.insert("bill_type", {"name": "Shoe"});
  }
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
