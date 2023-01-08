import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/expenses_calendar.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 24,
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
              width: size.width * 0.9,
              child: BlocBuilder<ExpensesBloc, ExpensesState>(
                builder: (context, state) {
                  print('first year: ${state.yearOfFirstInsert}');
                  return TransactionCalendar(
                      selectedDay: state.selectedDate,
                      firstDay: state.yearOfFirstInsert == null
                          ? DateTime.now().toUtc()
                          : DateTime.utc(state.yearOfFirstInsert!, 1, 1),
                      onDateSelected: (date, focus) {
                        context.read<ExpensesBloc>().add(ChangeDateEvent(date));
                        // print('selected to back: $date');
                      });
                },
              )),
        ),
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          width: size.width * 0.9,
          child: const ExpenseAnalysisSection(),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: size.width * 0.9,
          //  child: const Divider(),
        ),
        SizedBox(
            width: size.width * 0.9,
            child: BlocBuilder<ExpensesBloc, ExpensesState>(
                builder: (context, state) {
              var date = DateFormat("yyyy-MM-dd").format(state.selectedDate);
              return Text('Transactions on $date',
                  style: const TextStyle(fontSize: 16));
            })),
        const SizedBox(
          height: 20,
        ),
        const Expanded(child: ExpensesTransactions())
      ],
    );
  }
}

class ExpensesTransactions extends StatelessWidget {
  const ExpensesTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        children: const [EditableTransactionTile()],
      ),
    );
  }
}

class EditableTransactionTile extends StatelessWidget {
  const EditableTransactionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Bill: Fufu'),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Price: Necessity'),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Bill: Fufu'),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Price: Necessity'),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                TextButton(
                    style: buildButtonStyle(),
                    onPressed: () {},
                    child: const Text('View')),
                const SizedBox(
                  width: 12,
                ),
                TextButton(
                    style: buildButtonStyle(),
                    onPressed: () {},
                    child: const Text('Delete')),
                const SizedBox(
                  width: 12,
                ),
                TextButton(
                    style: buildButtonStyle(),
                    onPressed: () {},
                    child: const Text('update')),
              ],
            )
          ],
        ),
      ),
    );
  }

  ButtonStyle buildButtonStyle() {
    return TextButton.styleFrom(
        minimumSize: const Size(0, 0),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
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
        // const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(0, 0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {},
                child: const Text('Current Month')),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(0, 0),
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
