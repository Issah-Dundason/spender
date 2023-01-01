import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/app_bloc.dart';
import 'package:spender/bloc/app_state.dart';
import 'package:spender/pages/app_view.dart';
import 'package:spender/pages/expenses.dart';
import 'package:spender/pages/home_page.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClient dbClient = await DatabaseClient().init();

  AppRepository appRepo = AppRepository(dbClient);

  runApp(Spender(
    appRepo: appRepo,
  ));
}

class Spender extends StatelessWidget {
  final AppRepository appRepo;

  const Spender({super.key, required this.appRepo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: RepositoryProvider<AppRepository>.value(
          value: appRepo,
          child: BlocProvider<HomeCubit>(
              create: (_) => HomeCubit(), child: const AppView())),
    );
  }
}


