import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/bloc/profile/profile_event.dart';
import 'package:spender/pages/app_view.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/theme/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'bloc/app/app_cubit.dart';
import 'bloc/profile/profile_bloc.dart';
import 'bloc/stats/statistics.dart';

void main() async {
  sqfliteFfiInit();

  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClient dbClient = await DatabaseClient().init();

  AppRepository appRepo = AppRepository(dbClient);

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
          BlocProvider(
              lazy: false, create: (_) => StatsBloc(appRepo)..add(StartEvent()))
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
                      ..add(const LoadEvent())),
              ],
              child: const AppView(),
            )),
      ),
    );
  }
}
