import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';

import '../components/expenses_analysis.dart';
import '../components/expenses_calendar.dart';
import '../components/expenses_transactions.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: SizedBox(
              width: size.width * 0.9,
              child: BlocBuilder<ExpensesBloc, ExpensesState>(
                builder: (context, state) {
                  if (state.yearOfFirstInsert == null && !state.initialized) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return TransactionCalendar(
                      selectedDay: state.selectedDate,
                      firstYear: state.yearOfFirstInsert ?? DateTime.now().year,
                      onDateSelected: (date, focus) {
                        context.read<ExpensesBloc>().add(ChangeDateEvent(date));
                      });
                },
              )),
        ),
        const ExpansionTile(
          title: Text('Statistics'),
          children:  [
            ExpenseAnalysisSection()
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
              width: size.width * 0.9,
              child: BlocBuilder<ExpensesBloc, ExpensesState>(
                  builder: (context, state) {
                var date = DateFormat("yyyy-MM-dd").format(state.selectedDate);
                return Text('Transactions on $date',
                    style: const TextStyle(fontSize: 16));
              })),
        ),
        const SizedBox(
          height: 10,
        ),
        const Expanded(
            child: Align(
                alignment: Alignment.center, child: ExpensesTransactions()))
      ],
    );
  }
}
