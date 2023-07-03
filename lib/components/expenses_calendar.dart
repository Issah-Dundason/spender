import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:table_calendar/table_calendar.dart';

import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_event.dart';
import '../repository/expenditure_repo.dart';

class TransactionCalendar extends StatelessWidget {
  final CalendarFormat calendarFormat;

  const TransactionCalendar({
    Key? key,
    this.calendarFormat = CalendarFormat.week,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var last = DateTime.now().add(const Duration(days: 365 * 7));

    return BlocBuilder<ExpensesBloc, IExpensesState>(builder: (context, state) {
      if (state is! ExpensesSuccessfulState) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return TableCalendar(
        onDaySelected: (selected, _) {
          context.read<ExpensesBloc>().add(ExpensesDateChangeEvent(selected));
        },
        focusedDay: state.selectedDate,
        firstDay: DateTime(state.yearOfFirstInsert ?? DateTime.now().year),
        lastDay: last,
        calendarFormat: calendarFormat,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: _defaultBuilder,
          outsideBuilder: _defaultBuilder,
        ),
        headerStyle:
            const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: const CalendarStyle(
          isTodayHighlighted: false,
        ),
      );
    });
  }

  Widget _defaultBuilder(
      BuildContext context, DateTime actualDate, DateTime focusDate) {
    var appRepo = context.read<AppRepository>();
    var state = context.read<ExpensesBloc>().state as ExpensesSuccessfulState;
    String date = DateFormat('yyyy-MM-dd').format(actualDate);

    return FutureBuilder(
      future: appRepo.didTransactionsOnDay(date),
      builder: (context, snapshot) {
        return Container(
          width: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: DateUtils.isSameDay(state.selectedDate, actualDate)
                ? const Color(0xFFFF250c)
                : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(actualDate.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: DateUtils.isSameDay(state.selectedDate, actualDate)
                          ? Theme.of(context).colorScheme.onSecondary
                          : Colors.black,
                    )),
                const SizedBox(
                  height: 9,
                ),
                Visibility(
                  visible: snapshot.data != null && snapshot.data!,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: snapshot.data != null &&
                            snapshot.data! &&
                            DateUtils.isSameDay(state.selectedDate, actualDate)
                        ? Colors.white
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
