import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/bloc/profile/profile_event.dart';
import 'package:spender/model/bill.dart';
import 'package:spender/pages/app_view.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/theme/theme.dart';

import 'bloc/app/app_cubit.dart';
import 'bloc/profile/profile_bloc.dart';
import 'model/budget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClient dbClient = await DatabaseClient().init();

  AppRepository appRepo = AppRepository(dbClient);

  var a = DateTime(2023, 1, 1);

  var b = DateTime(2023, 1, 4);

  print('${a.difference(b).inDays}');

  // DateTime date = DateTime(2019, 02);
  //
  // var b = Budget(date.toIso8601String(), 323);
  //
  // appRepo.saveBudget(b);

  // var types = await dbClient.getProductTypes();
  //
  // var expenditure = Expenditure.withDate("First Insert", "For testing",
  //     PaymentType.momo, types[0], DateTime.utc(2019, 05, 01).toIso8601String(), 100, Priority.want);
  //
  // await dbClient.saveExpenditure(expenditure.toJson());

  //check shared preference
  final prefs = await SharedPreferences.getInstance();
  String? avatar = prefs.getString("profile/avatar");
  //if avatar is not there
  //set it with 'tracker.svg'
  avatar ??= 'tracker.svg';

  runApp(Spender(
    appRepo: appRepo,
    avatar: avatar,
  ));
}

class Spender extends StatelessWidget {
  final String avatar;
  final AppRepository appRepo;

  const Spender({super.key, required this.appRepo, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => appRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => ProfileBloc()
                ..add(ProfileAvatarChangeEvent(assetName: avatar))),
        ],
        child: MaterialApp(
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: MultiBlocProvider(
              providers: [
                BlocProvider(
                    create: (_) => HomeBloc(appRepo: appRepo)
                      ..add(const HomeInitializationEvent())),
                BlocProvider(create: (_) => AppCubit()),
                BlocProvider(
                    lazy: false,
                    create: (_) => ExpensesBloc(appRepo: appRepo)
                      ..add(const OnStartEvent())
                      ..add(const LoadEvent()))
              ],
              child: const AppView(),
            )),
      ),
    );
  }
}