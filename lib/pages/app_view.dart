import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/icons/icons.dart';

import '../bloc/app_bloc.dart';
import '../bloc/app_state.dart';
import 'expenses.dart';
import 'home_page.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit bloc) => bloc.state);
    return Scaffold(
      body: IndexedStack(
        index: selectedTab.current.index,
        children: const [HomePage(), ExpensesPage()],
      ),
      bottomNavigationBar: const MainBottomAppBar(),
    );
  }
}

class MainBottomAppBar extends StatelessWidget {
  const MainBottomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.current != HomeTab.bill) return;

        showModalBottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            context: context,
            builder: (_) => const _BillSheet());

        context.read<HomeCubit>().currentState =
            HomeState(current: state.previous);
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  color: state.current == HomeTab.home
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  alignment: Alignment.center,
                  splashRadius: 30,
                  onPressed: () => context.read<HomeCubit>().currentState =
                      HomeState(previous: state.current, current: HomeTab.home),
                  icon: const Icon(HomeIcon.icon)),
              CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: IconButton(
                      splashRadius: 30,
                      onPressed: () => context.read<HomeCubit>().currentState =
                          HomeState(
                              previous: state.current, current: HomeTab.bill),
                      icon: const Icon(AddIcon.icon))),
              IconButton(
                  color: state.current == HomeTab.expenses
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  splashRadius: 30,
                  onPressed: () => context.read<HomeCubit>().currentState =
                      HomeState(
                          previous: state.current, current: HomeTab.expenses),
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

class _BillSheet extends StatelessWidget {
  const _BillSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Modal'),
    );
  }
}
