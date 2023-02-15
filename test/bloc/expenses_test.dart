import 'package:flutter/material.dart';
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
    late Bill secondTestBill;
    late Bill thirdTestBill;
    late Bill fourthTestBill;

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
        },
        verify: (bloc) {
          var repo = AppRepository(dbClient);
          repo.getAllBills('2023-05-01').then(expectAsync1((bills) {
            expect(true, equals(bills.isEmpty));
          }));
        });

    blocTest('deletion of last recurrent(daily) bill updates parents end date',
        setUp: () async {
          var repo = AppRepository(dbClient);
          secondTestBill = (await repo.getAllBills('2023-04-15')).first;
        },
        wait: const Duration(milliseconds: 5),
        build: () {
          var repo = AppRepository(dbClient);
          return ExpensesBloc(appRepo: repo);
        },
        act: (bloc) => bloc.add(BillDeleteEvent(bill: secondTestBill)),
        expect: () {
          return [
            predicate<ExpensesState>((state) {
              return state.deleteState == DeleteState.deleting;
            }),
            predicate<ExpensesState>((state) {
              return state.deleteState == DeleteState.deleted;
            }),
          ];
        },
        verify: (bloc) {
          var repo = AppRepository(dbClient);
          for (var date in ['2023-04-12', '2023-04-13', '2023-04-14']) {
            repo.getAllBills(date).then(expectAsync1((bills) {
              expect(
                  true,
                  equals(DateUtils.isSameDay(
                      DateTime.parse(bills.first.endDate!),
                      DateTime.parse('2023-04-14'))));
            }));
          }
        });

    blocTest('deletion of last recurrent(weekly) bill updates parents end date',
        setUp: () async {
          var repo = AppRepository(dbClient);
          thirdTestBill = (await repo.getAllBills('2023-04-23')).first;
        },
        wait: const Duration(milliseconds: 5),
        build: () {
          var repo = AppRepository(dbClient);
          return ExpensesBloc(appRepo: repo);
        },
        act: (bloc) => bloc.add(BillDeleteEvent(bill: thirdTestBill)),
        expect: () {
          return [
            predicate<ExpensesState>((state) {
              return state.deleteState == DeleteState.deleting;
            }),
            predicate<ExpensesState>((state) {
              return state.deleteState == DeleteState.deleted;
            }),
          ];
        },
        verify: (bloc) {
          var repo = AppRepository(dbClient);
          repo.getAllBills('2023-04-16').then(expectAsync1((bills) {
            expect(
              true,
              equals(
                DateUtils.isSameDay(
                  DateTime.parse(bills.first.endDate!),
                  DateTime.parse('2023-04-16'),
                ),
              ),
            );
            expect(true, bills.first.title == 'Bill 5_2');
          }));
        });

    blocTest('deletion of recurrent bill creates exception',
      setUp: () async {
        var repo = AppRepository(dbClient);
        fourthTestBill = (await repo.getAllBills('2023-04-26')).first;
      },
      build: () {
        var repo = AppRepository(dbClient);
        return ExpensesBloc(appRepo: repo);
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
        },
      wait: const Duration(milliseconds: 5),
      verify: (bloc) {

        var repo = AppRepository(dbClient);

        repo.getAllBills('2023-04-26').then(expectAsync1((bills) {
          expect(true, equals(bills.isEmpty));
        }));

        repo.getAllBills('2023-04-25').then(expectAsync1((bills) {
          expect(true, equals(!bills.first.isGenerated));
          expect(bills.first.title, equals('Bill 5_3'));
        }));

        for(var date in [ '2023-04-27','2023-04-28']) {
          repo.getAllBills(date).then(expectAsync1((bills) {
            expect(true, equals(bills.first.isGenerated));
            expect(bills.first.title, equals('Bill 5_3'));
          }));
        }
      },
      act: (bloc) => bloc.add(BillDeleteEvent(bill: fourthTestBill),
      ),
    );
  });
}
