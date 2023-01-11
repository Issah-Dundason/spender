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
    var prime = Theme.of(context).colorScheme.primary;
    int i = 0;
    var colors = [const Color(0xFF524F5F), prime, const Color(0xFFF45737)];
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: BlocBuilder<ExpensesBloc, ExpensesState>(
        builder: (context, state) {
          if (state.transactions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Text("No Data"),
                  Icon(
                    Whiteboard.icon,
                    size: 150,
                  )
                ],
              ),
            );
          }
          return ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [
              ...state.transactions.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: EditableTransactionTile(
                    expenditure: e,
                  ),
                );
              }).toList()
            ],
          );
        },
      ),
    );
  }
}
