import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/pages/screens/narrow.dart';
import 'package:spender/pages/screens/wide.dart';
import '../bloc/app/app_cubit.dart';
import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_event.dart';

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {

  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(hours: 1), (timer) {
      context.read<ExpensesBloc>().add(const ExpensesLoadingEvent());
      context.read<HomeBloc>().add(const HomeInitializationEvent());
    });

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;

    if (query.width < 717 || query.height < 717) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    return LayoutBuilder(
      builder: (context, constraint) {

        if (constraint.maxWidth > 717) {
          return const WiderWidthView();
        }
        int index = context.read<AppCubit>().state.index;
        if (index == 2 || index == 3 || index == 4) {
          context.read<AppCubit>().currentState = AppTab.home;
        }
        context.read<ExpensesBloc>().add(const ExpensesLoadingEvent());
        return const NarrowWidthView();
      },
    );
  }
}
