import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/bloc/profile/profile_event.dart';
import 'package:spender/pages/app_view.dart';
import 'package:spender/pages/profile_page.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/theme/theme.dart';

import 'bloc/app/app_cubit.dart';
import 'bloc/profile/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClient dbClient = await DatabaseClient().init();

  AppRepository appRepo = AppRepository(dbClient);

  //check shared preference
  //if avatar is not there
  //set it with 'tracker.svg'
  //if it is there
  //just get it
  //pass the new or old on to profile bloc

  runApp(Spender(
    appRepo: appRepo,
  ));
}

class Spender extends StatelessWidget {
  final AppRepository appRepo;

  const Spender({super.key, required this.appRepo});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => appRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) =>
              ProfileBloc()
                ..add(ProfileAvatarChangeEvent(assetName: 'tracker.svg'))),
        ],
        child: MaterialApp(
            theme: AppTheme.lightTheme,
            routes: {AppProfile.routeName: (context) => const AppProfile()},
            home: MultiBlocProvider(
              providers: [
                BlocProvider(
                    create: (_) =>
                    HomeBloc(appRepo: appRepo)
                      ..add(const HomeInitializationEvent())),
                BlocProvider(create: (_) => AppCubit()),
              ],
              child: const AppView(),
            )),
      ),
    );
  }
}
