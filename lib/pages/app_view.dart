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
        index: selectedTab.index,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              splashRadius: 20,
              onPressed: () => context.read<HomeCubit>().tab = HomeTabs.home, icon: const Icon(HomeIcon.icon, size: 40)),
          CircleAvatar(
              child: IconButton(
                  splashRadius: 30,
                  onPressed: () {}, icon: const Icon(AddIcon.icon))),
          IconButton(
              splashRadius: 20,
              onPressed: () => context.read<HomeCubit>().tab = HomeTabs.expenses, icon: const Icon(CardIcon.icon, size: 40,)),
        ],
      ),
    );
  }
}