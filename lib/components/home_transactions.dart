import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home_state.dart';
import 'package:spender/components/transaction_tile.dart';
import 'package:spender/icons/icons.dart';

import '../bloc/home_bloc.dart';

class HomeTransactions extends StatelessWidget {
  const HomeTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Transactions",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () {},
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
                    ...state.transactionsToday
                        .map((t) {
                      return TransactionTile(
                        store: t.bill,
                        type: t.paymentType.name,
                        amount: t.cash,
                        date: t.formattedDate,
                      );
                    })
                        .toList()
                ],
              );
            },
          ),
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
