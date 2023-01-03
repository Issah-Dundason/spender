import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/model/expenditure.dart';
import 'package:spender/pages/app_view.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/theme/theme.dart';

import 'bloc/app_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClient dbClient = await DatabaseClient().init();
  var types = await dbClient.getProductTypes();

  var a = Expenditure.latest(
      "kskier", null, PaymentType.cash, types[0], 1020, Priority.want);

  var d = DateTime.now().add(Duration(days: 31));;

  var b = Expenditure.withDate(
      "kskier", null, PaymentType.cash, types[0], d.toIso8601String(), 1020, Priority.want,);

  await dbClient.saveExpenditure(a.toJson());
  await dbClient.saveExpenditure(b.toJson());

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
          child: BlocProvider<AppCubit>(
              create: (_) => AppCubit(), child: const AppView())),
    );
  }
}
