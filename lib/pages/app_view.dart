import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/components/appbar.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:spender/pages/screens/wide.dart';
import '../bloc/app/app_cubit.dart';
import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_event.dart';
import '../bloc/profile/profile_bloc.dart';
import '../components/bottom_appbar.dart';
import 'expenses.dart';
import 'home_page.dart';

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
      context.read<ExpensesBloc>().add(const LoadEvent());
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

    if(query.width < 450 || query.height < 450) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp
      ]);
    }

    return LayoutBuilder(
      builder: (context, constraint) {
        if (constraint.maxWidth > 450) {
          return const WiderWidthView();
        }
        int index = context.read<AppCubit>().state.index;
        if (index == 2 || index == 3) {
          context.read<AppCubit>().currentState = AppTab.home;
        }
        context.read<ExpensesBloc>().add(const LoadEvent());
        return const NarrowWidthView();
      },
    );
  }
}


class NarrowWidthView extends StatefulWidget {
  const NarrowWidthView({
    Key? key,
  }) : super(key: key);

  @override
  State<NarrowWidthView> createState() => _NarrowWidthViewState();
}

class _NarrowWidthViewState extends State<NarrowWidthView> {
  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((AppCubit bloc) => bloc.state);
    final profileState = context.select((ProfileBloc bloc) => bloc.state);
    return Scaffold(
      appBar: TopBar.getAppBar(
          context,
          toBeginningOfSentenceCase(selectedTab.name) as String,
          profileState.currentAvatar, () async {
        await Navigator.of(context).push(TopBar.createRoute());
        if (!mounted) return;
        context.read<HomeBloc>().add(const HomeInitializationEvent());
      }),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: IndexedStack(
        index: selectedTab.index,
        children: const [HomePage(), ExpensesPage()],
      ),
      bottomNavigationBar: const MainBottomAppBar(),
    );
  }
}
