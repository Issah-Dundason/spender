import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/bill/bill_bloc.dart';
import 'package:spender/pages/bill_view.dart';

import '../../bloc/bill/billing_state.dart';
import '../../components/expenses_calendar.dart';
import '../../components/expenses_transactions.dart';

class WiderScreenExpenses extends StatelessWidget {
  const WiderScreenExpenses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillBloc, IBillingState>(
      listener: (context, state) {
        if(state is BillUpdateState) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillView()));
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Row(
          children: [
            const Flexible(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: ExpensesTransactions(),
              ),
            ),
            Flexible(
                flex: 2,
                child: ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TransactionCalendar(),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
