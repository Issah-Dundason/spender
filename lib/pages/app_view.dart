import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/icons/icons.dart';
import 'package:spender/repository/expenditure_repo.dart';

import '../bloc/app_cubit.dart';
import '../bloc/app_state.dart';
import '../components/bill_view.dart';
import 'expenses.dart';
import 'home_page.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((AppCubit bloc) => bloc.state);
    return Scaffold(
      body: IndexedStack(
        index: selectedTab.current.index,
        children: const [HomePage(), ExpensesPage()],
      ),
      bottomNavigationBar: const _MainBottomAppBar(),
    );
  }
}

class _MainBottomAppBar extends StatelessWidget {
  const _MainBottomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state.current != AppTab.bill) return;
        var appRepo = context.read<AppRepository>();
        showModalBottomSheet(
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            context: context,
            builder: (_) => BillView(
                  appRepo: appRepo,
                ));

        context.read<AppCubit>().currentState =
            AppState(current: state.previous);
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
