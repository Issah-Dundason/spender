import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home_bloc.dart';
import 'package:spender/bloc/home_event.dart';
import 'package:spender/pages/app_view.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/theme/theme.dart';

import 'bloc/app_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClient dbClient = await DatabaseClient().init();
  var types = await dbClient.getProductTypes();

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
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => HomeBloc(appRepo: appRepo)
                    ..add(const HomeInitializationEvent())),
              BlocProvider(create: (_) => AppCubit())
            ],
            child: const AppView(),
          ),
        ));
  }
}
