import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spender/bloc/bill/bill_bloc.dart';
import 'package:spender/bloc/bill/billing_event.dart';
import 'package:spender/bloc/bill/billing_state.dart';
import 'package:spender/model/bill.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/test_database.dart';

void main() {
  sqfliteFfiInit();
  late BillBlocDatabaseClient dbClient;

  setUpAll(() async {
    dbClient = await BillBlocDatabaseClient().init();
  });

  blocTest(
    'can save recurring bills',
    build: () {
      var repo = AppRepository(dbClient);
      return BillBloc(appRepo: repo);
    },
    act: (bloc) {
      Bill bill = Bill(
          title: 'recurring bill',
          type: dbClient.billTypes[1],
          priority: Priority.want,
          paymentType: PaymentType.cheque,
          pattern: Pattern.daily,
          paymentDateTime: '2023-01-01T09:00:00.000',
          endDate: '2023-01-05T23:59:00.000',
          amount: 100);
      bloc.add(BillSaveEvent(bill));
    },
    wait: const Duration(milliseconds: 20),
    expect: verifyStateChanges,
    verify: (bloc) {
      var repo = AppRepository(dbClient);
      for (int i = 1; i <= 5; i++) {
        repo.getAllBills('2023-01-0$i').then(expectAsync1((bills) {
          var bill = bills.first;
          expect(bill.title, 'recurring bill');
          expect(bill.type, dbClient.billTypes[1]);
          expect(100, bill.amount);
        }));
      }
    },
  );

  group('can update generated bill', () {
    late Bill firstTest;
    late Bill secondTest;
    late Bill thirdTest;

    blocTest(
        'Updating a generated bill creates exception (new payment date can\'t be a future date)',
        setUp: () async {
          var repo = AppRepository(dbClient);
          firstTest = (await repo.getAllBills('2023-02-02')).first;
        },
        build: () {
          var repo = AppRepository(dbClient);
          return BillBloc(appRepo: repo);
        },
        wait: const Duration(milliseconds: 20),
        act: (bloc) {
          var bill =
              firstTest.copyWith(paymentDateTime: '2023-01-28', amount: 30);
          bloc.add(RecurrenceUpdateEvent(firstTest.paymentDateTime, bill));
        },
        expect: verifyStateChanges,
        verify: (bloc) {
          var repo = AppRepository(dbClient);
          repo.getAllBills('2023-01-28').then(expectAsync1((bills) {
            var bill = bills.first;
            expect(bill.parentId, equals(firstTest.parentId));
            expect(30, bill.amount);
          }));
        });

    blocTest('can update an exception',
        setUp: () async {
          var repo = AppRepository(dbClient);
          var bill = (await repo.getAllBills('2023-02-03')).first;
          var update = bill.copyWith(amount: 10);
          await repo.createException(update.toExceptionJson('2023-02-03'));
          secondTest = (await repo.getAllBills('2023-02-03')).first;
        },
        wait: const Duration(milliseconds: 20),
        act: (bloc) {
          var bill = secondTest.copyWith(amount: 12);
          var event = RecurrenceUpdateEvent(secondTest.paymentDateTime, bill);
          bloc.add(event);
        },
        expect: verifyStateChanges,
        build: () {
          return BillBloc(appRepo: AppRepository(dbClient));
        },
        verify: (bloc) {
          var repo = AppRepository(dbClient);
          repo.getAllBills('2023-02-03').then(expectAsync1((bills) {
            var bill = bills.first;
            expect(12, bill.amount);
            expect(true, bill.exceptionId != null);
          }));
        });

    blocTest(
      'can update generated bill and its future bills',
      setUp: () async {
        thirdTest =
            (await AppRepository(dbClient).getAllBills('2023-02-14')).first;
      },
      wait: const Duration(seconds: 2),
      build: () {
        return BillBloc(appRepo: AppRepository(dbClient));
      },
      act: (bloc) {
        var bill =
            thirdTest.copyWith(amount: 15, paymentType: PaymentType.momo);
        bloc.add(
            RecurrenceUpdateEvent('2023-02-14', bill, UpdateMethod.multiple));
      },
      expect: verifyStateChanges,
      verify: (bloc) {
        var repo = AppRepository(dbClient);
        repo.getAllBills('2023-02-13').then(expectAsync1((bills) {
          var bill = bills.first;
          expect(
              true,
              equals(DateUtils.isSameDay(DateTime.parse('2023-02-13'),
                  DateTime.parse(bill.endDate!))));
        }));

        for (var date in ['2023-02-14', '2023-02-15', '2023-02-16']) {
          repo.getAllBills(date).then(expectAsync1((bills) {
            var bill = bills.first;
            expect(bill.amount, 15);
            expect(bill.paymentType, PaymentType.momo);
          }));
        }
      },
    );
  });
}

verifyStateChanges() {
  return [
    predicate<BillingState>((state) {
      return state.processingState == ProcessingState.pending;
    }),
    predicate<BillingState>((state) {
      return state.processingState == ProcessingState.done;
    })
  ];
}
