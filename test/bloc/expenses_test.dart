// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:spender/bloc/expenses/expenses_bloc.dart';
// import 'package:spender/bloc/expenses/expenses_event.dart';
// import 'package:spender/bloc/expenses/expenses_state.dart';
// import 'package:spender/model/bill.dart';
// import 'package:spender/repository/expenditure_repo.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:bloc_test/bloc_test.dart';
//
// import '../database/test_database.dart';
//
// void main() async {
//   sqfliteFfiInit();
//   late  ExpensesBlocDatabaseClient dbClient;
//
//   setUpAll(() async {
//     dbClient = await  ExpensesBlocDatabaseClient().init();
//   });
//
//   group('can retrieve bills', () {
//     blocTest(
//       'can retrieve generated bill by date',
//       build: () {
//         AppRepository repo = AppRepository(dbClient);
//         return ExpensesBloc(appRepo: repo);
//       },
//       act: (bloc) => bloc.add(ExpensesDateChangeEvent(DateTime.parse('2023-02-06'))),
//       wait: const Duration(milliseconds: 5),
//       skip: 1,
//       expect: () {
//         return [
//           predicate<ExpensesSuccessfulState>((state) {
//             var bill = state.transactions[0];
//             return bill.isGenerated && bill.isRecurring;
//           })
//         ];
//       },
//     );
//
//     blocTest(
//       'can retrieve saved recurring bill by date',
//       build: () {
//         AppRepository repo = AppRepository(dbClient);
//         return ExpensesBloc(appRepo: repo);
//       },
//       act: (bloc) => bloc.add(ExpensesDateChangeEvent(DateTime.parse('2023-02-05'))),
//       wait: const Duration(milliseconds: 5),
//       skip: 1,
//       expect: () {
//         return [
//           predicate<ExpensesSuccessfulState>((state) {
//             var bill = state.transactions[0];
//             return !bill.isGenerated && bill.isRecurring;
//           })
//         ];
//       },
//     );
//
//     blocTest(
//       'can retrieve saved non recurring bill by date',
//       build: () {
//         AppRepository repo = AppRepository(dbClient);
//         return ExpensesBloc(appRepo: repo);
//       },
//       act: (bloc) => bloc.add(ExpensesDateChangeEvent(DateTime.parse('2023-02-13'))),
//       wait: const Duration(milliseconds: 5),
//       skip: 1,
//       expect: () {
//         return [
//           predicate<ExpensesSuccessfulState>((state) {
//             var bill = state.transactions[0];
//             return !bill.isGenerated &&
//                 !bill.isRecurring &&
//                 bill.endDate == null;
//           })
//         ];
//       },
//     );
//   });
//
//   group('can delete bills (SINGLE DELETE)', () {
//     const waitTime =  Duration(seconds: 2);
//     late Bill firstTestBill;
//     late Bill secondTestBill;
//     late Bill thirdTestBill;
//     late Bill fourthTestBill;
//     late Bill fifthTestBill;
//
//     blocTest('can delete non recurring bill',
//         setUp: () async {
//           var repo = AppRepository(dbClient);
//           firstTestBill = (await repo.getAllBills('2023-05-01')).first;
//         },
//         build: () {
//           var repo = AppRepository(dbClient);
//           return ExpensesBloc(appRepo: repo);
//         },
//         wait: waitTime,
//         act: (bloc) {
//           bloc.add(ExpensesBillDeleteEvent(bill: firstTestBill));
//         },
//         expect: verifyDeletionStateChanges,
//         verify: (bloc) {
//           var repo = AppRepository(dbClient);
//           repo.getAllBills('2023-05-01').then(expectAsync1((bills) {
//             expect(true, equals(bills.isEmpty));
//           }));
//         });
//
//
//     blocTest('deletion of last recurrent(daily) bill updates parents end date',
//         setUp: () async {
//           var repo = AppRepository(dbClient);
//           secondTestBill = (await repo.getAllBills('2023-04-15')).first;
//         },
//         wait: waitTime,
//         build: () {
//           var repo = AppRepository(dbClient);
//           return ExpensesBloc(appRepo: repo);
//         },
//         act: (bloc) => bloc.add(ExpensesBillDeleteEvent(bill: secondTestBill)),
//         expect: verifyDeletionStateChanges,
//         verify: (bloc) {
//           var repo = AppRepository(dbClient);
//           for (var date in ['2023-04-12', '2023-04-13', '2023-04-14']) {
//             repo.getAllBills(date).then(expectAsync1((bills) {
//               expect(
//                   true,
//                   equals(DateUtils.isSameDay(
//                       DateTime.parse(bills.first.endDate!),
//                       DateTime.parse('2023-04-14'))));
//             }));
//           }
//         });
//
//     blocTest('deletion of last recurrent(weekly) bill updates parents end date',
//         setUp: () async {
//           var repo = AppRepository(dbClient);
//           thirdTestBill = (await repo.getAllBills('2023-04-23')).first;
//         },
//         wait: waitTime,
//         build: () {
//           var repo = AppRepository(dbClient);
//           return ExpensesBloc(appRepo: repo);
//         },
//         act: (bloc) => bloc.add(ExpensesBillDeleteEvent(bill: thirdTestBill)),
//         expect: verifyDeletionStateChanges,
//         verify: (bloc) {
//           var repo = AppRepository(dbClient);
//           repo.getAllBills('2023-04-16').then(expectAsync1((bills) {
//             expect(
//               true,
//               equals(
//                 DateUtils.isSameDay(
//                   DateTime.parse(bills.first.endDate!),
//                   DateTime.parse('2023-04-16'),
//                 ),
//               ),
//             );
//             expect(true, bills.first.title == 'Bill 5_2');
//           }));
//         });
//
//     blocTest(
//       'deletion of recurrent bill creates exception',
//       setUp: () async {
//         var repo = AppRepository(dbClient);
//         fourthTestBill = (await repo.getAllBills('2023-04-26')).first;
//       },
//       build: () {
//         var repo = AppRepository(dbClient);
//         return ExpensesBloc(appRepo: repo);
//       },
//       expect: verifyDeletionStateChanges,
//       wait: waitTime,
//       verify: (bloc) {
//         var repo = AppRepository(dbClient);
//
//         repo.getAllBills('2023-04-26').then(expectAsync1((bills) {
//           expect(true, equals(bills.isEmpty));
//         }));
//
//         repo.getAllBills('2023-04-25').then(expectAsync1((bills) {
//           expect(true, equals(!bills.first.isGenerated));
//           expect(bills.first.title, equals('Bill 5_3'));
//         }));
//
//         for (var date in ['2023-04-27', '2023-04-28']) {
//           repo.getAllBills(date).then(expectAsync1((bills) {
//             expect(true, equals(bills.first.isGenerated));
//             expect(bills.first.title, equals('Bill 5_3'));
//           }));
//         }
//       },
//       act: (bloc) => bloc.add(
//         ExpensesBillDeleteEvent(bill: fourthTestBill),
//       ),
//     );
//
//     blocTest(
//       'deletion of recurrent bill (parent) creates an exception',
//       setUp: () async {
//         var repo = AppRepository(dbClient);
//         fifthTestBill = (await repo.getAllBills('2023-04-29')).first;
//       },
//       build: () {
//         var repo = AppRepository(dbClient);
//         return ExpensesBloc(appRepo: repo);
//       },
//       expect: verifyDeletionStateChanges,
//       wait: waitTime,
//       verify: (bloc) {
//         var repo = AppRepository(dbClient);
//
//         repo.getAllBills('2023-04-29').then(expectAsync1((bills) {
//           expect(true, equals(bills.isEmpty));
//         }));
//
//         repo.getAllBills('2023-04-30').then(expectAsync1((bills) {
//           expect(true, equals(bills.first.isGenerated));
//           expect(bills.first.title, equals('Bill 5_4'));
//           expect(bills.first.amount, equals(10));
//         }));
//       },
//       act: (bloc) => bloc.add(ExpensesBillDeleteEvent(bill: fifthTestBill)),
//     );
//   });
//
//   group('can delete bills (MULTIPLE DELETE)', () {
//     late Bill firstTestBill;
//     late Bill secondTestBill;
//
//     const waitTime = Duration(seconds: 2);
//
//     blocTest('multiple deletion of generated bills changes end date of parent',
//         setUp: () async {
//           var repo = AppRepository(dbClient);
//           firstTestBill = (await repo.getAllBills('2023-04-03')).first;
//         },
//         build: () {
//           var repo = AppRepository(dbClient);
//           return ExpensesBloc(appRepo: repo);
//         },
//         expect: verifyDeletionStateChanges,
//         wait: waitTime,
//         verify: (bloc) {
//           var repo = AppRepository(dbClient);
//
//           for (var date in ['2023-04-01', '2023-04-02']) {
//             repo.getAllBills(date).then(expectAsync1((bills) {
//               expect(bills.first.title, equals('Bill 5_1'));
//               expect(
//                   true,
//                   DateUtils.isSameDay(
//                     DateTime.parse(bills.first.endDate!),
//                     DateTime.parse('2023-04-02'),
//                   ),);
//             }));
//           }
//           for (var date in ['2023-04-03', '2023-04-04', '2023-04-05']) {
//             repo.getAllBills(date).then(expectAsync1((bills) {
//               expect(true, equals(bills.isEmpty));
//             }));
//           }
//         },
//         act: (bloc) => bloc.add(ExpensesBillDeleteEvent(
//             bill: firstTestBill, method: DeleteMethod.multiple)));
//
//     blocTest('deletion of parent ensures no generated bills are returned',
//         setUp: () async {
//           var repo = AppRepository(dbClient);
//           secondTestBill = (await repo.getAllBills('2023-04-06')).first;
//         },
//         build: () {
//           var repo = AppRepository(dbClient);
//           return ExpensesBloc(appRepo: repo);
//         },
//         expect: verifyDeletionStateChanges,
//         wait: waitTime,
//         verify: (bloc) {
//           var repo = AppRepository(dbClient);
//           expect(true, !secondTestBill.isGenerated);
//           for (var date in ['2023-04-06', '2023-04-07', '2023-04-08']) {
//             repo.getAllBills(date).then(expectAsync1((bills) {
//               expect(true, equals(bills.isEmpty));
//             }));
//           }
//         },
//         act: (bloc) => bloc.add(ExpensesBillDeleteEvent(
//             bill: secondTestBill, method: DeleteMethod.multiple)));
//   });
//
// }
//
// verifyDeletionStateChanges() {
//   return [
//     predicate<ExpensesSuccessfulState>((state) {
//       return state.deleteState == DeleteState.deleting;
//     }),
//     predicate<ExpensesSuccessfulState>((state) {
//       return state.deleteState == DeleteState.deleted;
//     }),
//   ];
// }
