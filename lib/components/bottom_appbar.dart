import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/bill/bill_bloc.dart';

import '../bloc/app/app_cubit.dart';
import '../bloc/bill/billing_event.dart';
import '../icons/icons.dart';

class MainBottomAppBar extends StatelessWidget {
  const MainBottomAppBar({Key? key}) : super(key: key);

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
                      onPressed: () => _addBill(context),
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

  void _addBill(BuildContext context) {
    context.read<BillBloc>().add(const BillCreationEvent());
  }
}