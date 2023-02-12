import 'package:path_provider/path_provider.dart';
import 'package:spender/service/database.dart';
import 'package:spender/service/queries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TestDatabaseClient extends DatabaseClient {
  static const String _databaseName = "spenderTest.app";

  @override
  Future<TestDatabaseClient> init() async {
    await _openDatabase();
    return this;
  }

  Future<void> _openDatabase() async {
    var dir = await getApplicationDocumentsDirectory();
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    _create(db);
  }

  void _create(Database db) async {
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

}
