import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:spender/model/bill.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/test_database.dart';

void main() async {
  sqfliteFfiInit();
  TestDatabaseClient dbClient = await TestDatabaseClient().init();

  test('gets events by date', () async {

    //Arrange
    AppRepository repo = AppRepository(dbClient);
    ExpensesBloc sut = ExpensesBloc(appRepo: repo);

    var types = await repo.getBillTypes();

    var bill = Bill.fromJson({
      'title': 'Bill',
      'priority': 'need',
      'payment_type': 'cash',
      'pattern': 1,
      'payment_datetime': '2023-02-12T23:00:00.000',
      'amount': 200,
      'end_date': '2023-02-13T23:59:00.000',
      'type': types[0].toJson()
    });
    await repo.saveBill(bill);
    int? id;
    late List<Object> savedBill;

    sut.stream.listen((event) {
      print(event);
    });

    sut.add(ChangeDateEvent(DateTime.parse('2023-02-12')));
  });


}
