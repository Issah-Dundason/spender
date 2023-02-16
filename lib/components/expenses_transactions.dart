import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_state.dart';
import '../icons/icons.dart';
import 'expense_transaction_tile.dart';

class ExpensesTransactions extends StatelessWidget {
  const ExpensesTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: BlocBuilder<ExpensesBloc, ExpensesState>(

        builder: (context, state) {
          if (state.transactions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                alignment: Alignment.center,
                children:  [
                  const Text("No Data"),
                  Icon(
                    Whiteboard.icon,
                    size: 150,
                    color: Theme.of(context).colorScheme.primary,
                  )
                ],
              ),
            );
          }
          return ListView(

            physics:const BouncingScrollPhysics(),
            children: [
              ...state.transactions.map((e) {
                return EditableTransactionTile(
                  bill: e,
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  tileColor: Colors.grey[300],
                );
              }).toList()
            ],
          );
        },
      ),
    );
  }
}

