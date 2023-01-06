import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/budget/budget_state.dart';

import '../bloc/budget/budget_bloc.dart';
import '../util/app_utils.dart';


class BudgetTable extends StatelessWidget {
  const BudgetTable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: DataTable(columns: const [
            DataColumn(
              label: Text(
                'ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ], rows:  [
            ...state.budgets.map((b) {
              return DataRow(cells: [
                DataCell(Text('${b.id}')),
                DataCell(Text('Ȼ ${AppUtils.amountPresented(b.amount)}')),
                DataCell(Text(b.formattedDate)),
              ]);
            }).toList()
          ]),
        );
      },
    );
  }
}