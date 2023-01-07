import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/expenses_calendar.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ListView(
      children: [
        const SizedBox(
          height: 24,
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
              width: size.width * 0.9,
              child: TransactionCalendar(
                selectedDay: DateTime.now(),
              )),
        ),
        const SizedBox(
          height: 30,
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: size.width * 0.9,
            child: const ExpenseAnalysisSection(),
          ),
        )
      ],
    );
  }
}

class ExpenseAnalysisSection extends StatelessWidget {
  const ExpenseAnalysisSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 18),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {},
                child: const Text('Current Month')),
            const SizedBox(width: 10,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {},
                child: const Text('Overall'))
          ],
        ),
      ],
    );
  }
}
