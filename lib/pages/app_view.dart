import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/components/appbar.dart';
import 'package:spender/icons/icons.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import '../bloc/app/app_cubit.dart';
import '../bloc/bill/bill_bloc.dart';
import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_event.dart';
import '../bloc/profile/profile_bloc.dart';
import 'bill_view.dart';
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
    return LayoutBuilder(
      builder: (context, constraint) {
        if (constraint.maxWidth > 450) {
          return const WiderWidthView();
        }
        int index = context.read<AppCubit>().state.index;
        if (index == 2 || index == 3) {
          context.read<AppCubit>().currentState = AppTab.home;
        }
        return const NarrowWidthView();
      },
    );
  }
}

class WiderWidthView extends StatelessWidget {
  const WiderWidthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppTab>(
      builder: (context, state) {
        final profileState = context.select((ProfileBloc bloc) => bloc.state);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            leading: ProfileIcon(assetName: profileState.currentAvatar,),
            title: const Text('Tracedi'),
            backgroundColor: Colors.white,
            centerTitle: true,
            foregroundColor: Colors.black,
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: () => setState(context, AppTab.home),
                            style: getStyle(AppTab.home, state, context),
                            child: const Text(
                              'Home',
                              textAlign: TextAlign.left,
                            )),
                        TextButton(
                            onPressed: () => setState(context, AppTab.expenses),
                            style: getStyle(AppTab.expenses, state, context),
                            child: const Text('Expenses')),
                        TextButton(
                            onPressed: () => setState(context, AppTab.add),
                            style: getStyle(AppTab.add, state, context),
                            child: const Text('Add Bill')),
                        TextButton(
                            onPressed: () => setState(context, AppTab.settings),
                            style: getStyle(AppTab.settings, state, context),
                            child: const Text('Settings'))
                      ],
                    ),
                  )),
              // Container(width: 10, color: Colors.blue,),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey.shade300)))
                    ),
                  )
            ],
          ),
        );
      },
    );
  }

  ButtonStyle? getStyle(AppTab actual, AppTab selected, BuildContext context) {
    if(actual != selected) return null;
    return TextButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      minimumSize: const Size.fromHeight(40),
      padding: EdgeInsets.zero,
      foregroundColor: Colors.white,
       shape: const StadiumBorder()
    );
  }

  void setState(BuildContext context, AppTab tab) {
    context.read<AppCubit>().currentState = tab;
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
      bottomNavigationBar: const _MainBottomAppBar(),
    );
  }
}

class _MainBottomAppBar extends StatefulWidget {
  const _MainBottomAppBar({Key? key}) : super(key: key);

  @override
  State<_MainBottomAppBar> createState() => _MainBottomAppBarState();
}

class _MainBottomAppBarState extends State<_MainBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppTab>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  color: state == AppTab.home
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  alignment: Alignment.center,
                  splashRadius: 30,
                  onPressed: () =>
                      context.read<AppCubit>().currentState = AppTab.home,
                  icon: const Icon(HomeIcon.icon)),
              CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: IconButton(
                      splashRadius: 30,
                      onPressed: _addBill,
                      icon: const Icon(AddIcon.icon))),
              IconButton(
                  color: state == AppTab.expenses
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  splashRadius: 30,
                  onPressed: () =>
                      context.read<AppCubit>().currentState = AppTab.expenses,
                  icon: const Icon(
                    CardIcon.icon,
                  )),
            ],
          ),
        );
      },
    );
  }

  void _addBill() async {
    await _showAddBillView();
    if (!mounted) return;
    context.read<ExpensesBloc>().add(const LoadEvent());
    context.read<HomeBloc>().add(const HomeInitializationEvent());
  }

  Future<dynamic> _showAddBillView() async {
    var appRepo = context.read<AppRepository>();
    var billTypes = await appRepo.getBillTypes();

    if (!mounted) return;

    return Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider(
            create: (_) {
              return BillBloc(appRepo: appRepo);
            },
            child: BillView(
              billTypes: billTypes,
            ))));
  }
}
