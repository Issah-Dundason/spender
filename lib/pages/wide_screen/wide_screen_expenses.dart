import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bloc/expenses/expenses_bloc.dart';
import '../../bloc/expenses/expenses_event.dart';
import '../../bloc/expenses/expenses_state.dart';
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
                children: [

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocBuilder<ExpensesBloc, ExpensesState>(
                      builder: (context, state) {
                        if (state.yearOfFirstInsert == null &&
                            !state.initialized) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return TransactionCalendar(
                            selectedDay: state.selectedDate,
                            calendarFormat: CalendarFormat.month,
                            firstYear:
                            state.yearOfFirstInsert ?? DateTime.now().year,
                            onDateSelected: (date, focus) {
                              context
                                  .read<ExpensesBloc>()
                                  .add(ChangeDateEvent(date));
                            });
                      },
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
