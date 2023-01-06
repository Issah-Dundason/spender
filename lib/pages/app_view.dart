import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/components/appbar.dart';
import 'package:spender/icons/icons.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import '../bloc/app/app_cubit.dart';
import '../bloc/app/app_state.dart';
import '../bloc/profile/profile_bloc.dart';
import '../components/bill_view.dart';
import 'expenses.dart';
import 'home_page.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((AppCubit bloc) => bloc.state);
    final profileState = context.select((ProfileBloc bloc) => bloc.state);
    return Scaffold(
      appBar: TopBar.getAppBar(context, toBeginningOfSentenceCase(selectedTab.current.name) as String,
          profileState.currentAvatar),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: IndexedStack(
        index: selectedTab.current == AppTab.bill
            ? selectedTab.previous.index
            : selectedTab.current.index,
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
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) async {
        if (state.current != AppTab.bill) return;
        var appRepo = context.read<AppRepository>();
        var data = await showModalBottomSheet(
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            context: context,
            builder: (_) => BillView(
                  appRepo: appRepo,
                ));
        if (!mounted) return;
        this.context.read<AppCubit>().currentState =
            AppState(current: state.previous);
        if (data != true) return;
        this.context.read<HomeBloc>().add(const HomeInitializationEvent());
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  color: state.current == AppTab.home
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  alignment: Alignment.center,
                  splashRadius: 30,
                  onPressed: () => context.read<AppCubit>().currentState =
                      AppState(previous: state.current, current: AppTab.home),
                  icon: const Icon(HomeIcon.icon)),
              CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: IconButton(
                      splashRadius: 30,
                      onPressed: () => context.read<AppCubit>().currentState =
                          AppState(
                              previous: state.current, current: AppTab.bill),
                      icon: const Icon(AddIcon.icon))),
              IconButton(
                  color: state.current == AppTab.expenses
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  splashRadius: 30,
                  onPressed: () => context.read<AppCubit>().currentState =
                      AppState(
                          previous: state.current, current: AppTab.expenses),
                  icon: const Icon(
                    CardIcon.icon,
                  )),
            ],
          ),
        );
      },
    );
  }
}
