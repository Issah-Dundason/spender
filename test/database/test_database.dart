import 'package:spender/model/bill.dart';
import 'package:spender/model/bill_type.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/service/queries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ExpensesBlocDatabaseClient extends DatabaseClient {
  //add types before saving
  var testJson = [
    {
      'title': 'Bill 1',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 1,
      'payment_datetime': '2023-01-01T23:00:00.000',
      'amount': 200,
      'end_date': '2023-01-10T23:59:00.000',
    },
    //for testing recurring bill retrieval
    {
      'title': 'Bill 2',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 1,
      'payment_datetime': '2023-02-05T23:00:00.000',
      'amount': 200,
      'end_date': '2023-02-10T23:59:00.000',
    },
    //for testing non recurring bill retrieval,
    {
      'title': 'Bill 3',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 0,
      'payment_datetime': '2023-02-13T23:00:00.000',
      'amount': 200,
    },
    {
      'title': 'Bill 4',
      'priority': 'want',
      'payment_type': 'cash',
      'pattern': 0,
      'payment_datetime': '2023-03-01T23:00:00.000',
      'amount': 200,
    },
    //for recurring bill deletion
    {
      'title': 'Bill 5_1',
      'priority': 'want',
      'payment_type': 'momo',
      'pattern': 1,
      'payment_datetime': '2023-04-01T16:00:00.000',
      'amount': 10,
      'end_date': '2023-04-05T23:59:00.000',
    },
    {
      'title': 'Bill 5_1_2',
      'priority': 'want',
      'payment_type': 'momo',
      'pattern': 1,
      'payment_datetime': '2023-04-06T16:00:00.000',
      'amount': 10,
      'end_date': '2023-04-08T23:59:00.000',
    },
    {
      'title': 'Bill 5',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 1,
      'payment_datetime': '2023-04-12T23:00:00.000',
      'amount': 200,
      'end_date': '2023-04-15T23:59:00.000',
    },
    {
      'title': 'Bill 5_2',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 2,
      'payment_datetime': '2023-04-16T23:00:00.000',
      'amount': 200,
      'end_date': '2023-04-23T23:59:00.000',
    },
    {
      'title': 'Bill 5_3',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 1,
      'payment_datetime': '2023-04-25T12:00:00.000',
      'amount': 200,
      'end_date': '2023-04-28T23:59:00.000',
    },
    {
      'title': 'Bill 5_4',
      'priority': 'want',
      'payment_type': 'momo',
      'pattern': 1,
      'payment_datetime': '2023-04-29T16:00:00.000',
      'amount': 10,
      'end_date': '2023-04-30T23:59:00.000',
    },
    //for testing non recurring bill deletion
    {
      'title': 'Bill 6',
      'priority': 'want',
      'payment_type': 'cash',
      'pattern': 0,
      'payment_datetime': '2023-05-01T23:00:00.000',
      'amount': 200,
    }
  ];

  @override
  Future<ExpensesBlocDatabaseClient> init() async {
    await _openDatabase();
    return this;
  }

  Future<void> _openDatabase() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await _create(db);
  }

  Future<void> _create(Database db) async {
    await db.execute(Query.billTypeTable);
    await db.execute(Query.expenditureTable);
    await db.execute(Query.budgetTable);
    await db.execute(Query.expenditureExceptionTable);

    await db.delete('bill_type');
    await db.delete('expenditure');
    await db.delete('budget');

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

    AppRepository repo = AppRepository(this);

    var types = await repo.getBillTypes();

    for (var json in testJson) {
      json['type'] = types[0].toJson();
      await repo.saveBill(Bill.fromJson(json));
    }
  }
}

class BillBlocDatabaseClient extends DatabaseClient {
  late List<BillType> billTypes;
  //add types before saving
  var testJson = [
    //for updating generated bill
    {
      'title': 'Bill 2',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 1,
      'payment_datetime': '2023-02-01T23:00:00.000',
      'amount': 200,
      'end_date': '2023-02-04T23:59:00.000',
    },
    //for testing non recurring bill retrieval,
    {
      'title': 'Bill 3',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 1,
      'payment_datetime': '2023-02-13T23:00:00.000',
      'amount': 200,
      'end_date': '2023-02-16T23:59:00.000',
    },
  ];

  @override
  Future<BillBlocDatabaseClient> init() async {
    await _openDatabase();
    return this;
  }

  Future<void> _openDatabase() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await _create(db);
  }

  Future<void> _create(Database db) async {
    await db.execute(Query.billTypeTable);
    await db.execute(Query.expenditureTable);
    await db.execute(Query.budgetTable);
    await db.execute(Query.expenditureExceptionTable);

    await db.delete('bill_type');
    await db.delete('expenditure');
    await db.delete('budget');

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

    AppRepository repo = AppRepository(this);

    var types = await repo.getBillTypes();
    billTypes = types;

    for (var json in testJson) {
      json['type'] = types[0].toJson();
      await repo.saveBill(Bill.fromJson(json));
    }
  }
}
