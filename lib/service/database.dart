import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/model.dart';

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

  Future deleteExpenditure(int id) async {
    await _db.delete("expenditure", where: "id = ?", whereArgs: [id]);
  }

  Future<Budget> getBudget() {
    throw UnimplementedError();
  }


  ///date is a string of date formatted as yyyy-MM
  Future<List<Expenditure>> getByYearAndMonth(String date) async {
    var result = await _db.rawQuery('''
      SELECT e.id as eid, 
            e.product AS eproduct, 
            e.description as edesc, 
            e.payment_type as epay, 
            e.price as eprice, e.date as edate, 
            e.priority as epri, 
            p.id as pid, p.name as pname
      FROM expenditure e 
      JOIN product_type p 
      ON e.product_type_id = p.id WHERE strftime('%Y-%m', e.date) = ?;
    ''', [date]);
    return result.map((e) => Expenditure.fromMap(e)).toList();
  }

  Future<List<Expenditure>> getExpenditureByDate(String date) async {
    var result = await _db.rawQuery('''
      SELECT e.id as eid, 
            e.product AS eproduct, 
            e.description as edesc, 
            e.payment_type as epay, 
            e.price as eprice, e.date as edate, 
            e.priority as epri, 
            p.id as pid, p.name as pname
      FROM expenditure e 
      JOIN product_type p 
      ON e.product_type_id = p.id WHERE date = ?;
    ''', [date]);
    return result.map((e) => Expenditure.fromMap(e)).toList();
  }

  Future<List<ProductType>> getProductTypes() async {
    var result = await _db.query("product_type");
    return result
        .map((e) => ProductType(e["id"] as int, e["name"] as String))
        .toList();
  }

  Future saveExpenditure(Map<String, dynamic> map) async {
    await _db.insert("expenditure", map);
  }

  Future<List<MonthSpending>> getAmountSpentEachMonth(String year) async {
    var result = await _db.rawQuery('''SELECT strftime('%m',date) as month, 
          SUM(price) as amount FROM expenditure GROUP BY 1 HAVING strftime('%Y',date) = ?''',
        [year]);
    return result
        .map((q) =>
            MonthSpending(int.parse(q["month"] as String), q["amount"] as int))
        .toList();
  }

  Future _create(Database db, int i) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_type (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT  NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenditure (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        product TEXT NOT NULL,
        description TEXT,
        payment_type INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        product_type_id INTEGER,
        price INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (product_type_id) REFERENCES product_type(id)
      );
    ''');
    await db.insert("product_type", {"name": "Food"});
    await db.insert("product_type", {"name": "Shoe"});
  }
}

class MonthSpending {
  int month;
  int amount;

  MonthSpending(this.month, this.amount);

  @override
  String toString() {
    return '{month: $month, amount: $amount}';
  }
}
