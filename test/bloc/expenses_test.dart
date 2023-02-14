import 'package:flutter_test/flutter_test.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:spender/model/bill.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bloc_test/bloc_test.dart';

import '../database/test_database.dart';

void main() async {
  sqfliteFfiInit();
  late TestDatabaseClient dbClient;

  setUpAll(() async {
    dbClient = await TestDatabaseClient().init();
  });

  group('can retrieve bills', () {
    blocTest(
      'can retrieve generated bill by date',
      build: () {
        AppRepository repo = AppRepository(dbClient);
        return ExpensesBloc(appRepo: repo);
      },
      act: (bloc) => bloc.add(ChangeDateEvent(DateTime.parse('2023-02-06'))),
      wait: const Duration(milliseconds: 5),
      skip: 1,
      expect: () {
        return [
          predicate<ExpensesState>((state) {
            var bill = state.transactions[0];
            return bill.isGenerated && bill.isRecurring;
          })
        ];
      },
    );

    blocTest(
      'can retrieve saved recurring bill by date',
      build: () {
        AppRepository repo = AppRepository(dbClient);
        return ExpensesBloc(appRepo: repo);
      },
      act: (bloc) => bloc.add(ChangeDateEvent(DateTime.parse('2023-02-05'))),
      wait: const Duration(milliseconds: 5),
      skip: 1,
      expect: () {
        return [
          predicate<ExpensesState>((state) {
            var bill = state.transactions[0];
            return !bill.isGenerated && bill.isRecurring;
          })
        ];
      },
    );

    blocTest(
      'can retrieve saved non recurring bill by date',
      build: () {
        AppRepository repo = AppRepository(dbClient);
        return ExpensesBloc(appRepo: repo);
      },
      act: (bloc) => bloc.add(ChangeDateEvent(DateTime.parse('2023-02-13'))),
      wait: const Duration(milliseconds: 5),
      skip: 1,
      expect: () {
        return [
          predicate<ExpensesState>((state) {
            var bill = state.transactions[0];
            return !bill.isGenerated &&
                !bill.isRecurring &&
                bill.endDate == null;
          })
        ];
      },
    );
  });

  group('can delete bills', () {
    late Bill firstTestBill;

    blocTest('can delete non recurring bill',
        setUp: () async {
          var repo = AppRepository(dbClient);
          firstTestBill = (await repo.getAllBills('2023-05-01')).first;
        },
        build: () {
          var repo = AppRepository(dbClient);
          return ExpensesBloc(appRepo: repo);
        },
        wait: const Duration(milliseconds: 5),
        act: (bloc) {
          bloc.add(BillDeleteEvent(bill: firstTestBill));
        },
        expect: () {
          return [
            predicate<ExpensesState>((state) {
              return state.deleteState == DeleteState.deleting;
            }),
            predicate<ExpensesState>((state) {
              return state.deleteState == DeleteState.deleted;
            }),
          ];
        }, verify: (bloc) {
          var repo = AppRepository(dbClient);
          repo.getAllBills('2023-05-01').then(expectAsync1((bills) {
            expect(true, equals(bills.isEmpty));
          }));
        });
  });
}
