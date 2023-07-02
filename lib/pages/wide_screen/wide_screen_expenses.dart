import 'package:flutter/material.dart';

import '../../components/expenses_calendar.dart';
import '../../components/expenses_transactions.dart';

class WiderScreenExpenses extends StatelessWidget {
  const WiderScreenExpenses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
