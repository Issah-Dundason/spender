import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/home/home_state.dart';
import 'package:spender/components/receipt.dart';
import 'package:spender/components/transaction_tile.dart';
import 'package:spender/icons/icons.dart';
import 'package:spender/model/bill.dart';

import '../bloc/app/app_cubit.dart';
import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/home/home_bloc.dart';
import '../util/app_utils.dart';

class HomeTransactions extends StatelessWidget {
  const HomeTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Transactions",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                TextButton(
                    onPressed: () {
                      context.read<AppCubit>().currentState = AppTab.expenses;
                      context.read<ExpensesBloc>().add(ChangeDateEvent(DateTime.now()));
                    },
                    child: Text(
                      "View All",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    )),
              ],
            ),
            if (state.transactionsToday.isEmpty)
              const _NoTransaction()
            else
              ...state.transactionsToday.map((t) {
                return GestureDetector(
                  onTap: () => _onTransactionTap(context, t),
                  child: TransactionTile(
                    image: t.type.image,
                    bill: t.title,
                    type: t.paymentType.name,
                    amount: AppUtils.amountPresented(t.amount),
                    date: t.formattedDate,
                  ),
                );
              }).toList()
          ],
        );
      },
    );
  }

  void _onTransactionTap(BuildContext context, Bill e) async {
    await showDialog(
        context: context,
        builder: (_) => Receipt(
              expenditure: e,
            ));
  }
}

class _NoTransaction extends StatelessWidget {
  const _NoTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Whiteboard.icon,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        const Text(
          'No transactions today',
        )
      ],
    );
  }
}
