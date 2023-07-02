import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:table_calendar/table_calendar.dart';

import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_event.dart';
import '../repository/expenditure_repo.dart';

class TransactionCalendar extends StatefulWidget {
  final CalendarFormat calendarFormat;

  const TransactionCalendar({
    Key? key,
    this.calendarFormat = CalendarFormat.week,
  }) : super(key: key);

  @override
  State<TransactionCalendar> createState() => _TransactionCalendarState();
}

class _TransactionCalendarState extends State<TransactionCalendar> {
  DateTime selectedDay = DateTime.now();
  int firstYear = 2012;

  @override
  void initState() {
    context.read<ExpensesBloc>().stream.listen((state) {
      if(state is! ExpensesSuccessfulState) {
        return;
      }

      if(state.yearOfFirstInsert == null) {
        return;
      }

      setState(() => firstYear = state.yearOfFirstInsert!);

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var last = DateTime.now().add(const Duration(days: 2));
    print("running");
    return TableCalendar(

      key: Key(DateTime.now().toString()),
      onDaySelected: _onDateSelected,
      focusedDay: selectedDay,
      firstDay: DateTime(firstYear),
      lastDay: last,
      calendarFormat: widget.calendarFormat,
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
  }

  void _onDateSelected(DateTime date, DateTime focus) {
    setState(() {
      selectedDay = date;
    });
    context.read<ExpensesBloc>().add(ExpensesDateChangeEvent(date));
  }

  Widget _defaultBuilder(
      BuildContext context, DateTime actualDate, DateTime focusDate) {
    var appRepo = context.read<AppRepository>();
    String date = DateFormat('yyyy-MM-dd').format(actualDate);

    return FutureBuilder(
      future: appRepo.didTransactionsOnDay(date),
      builder: (context, snapshot) {
        return Container(
          width: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: DateUtils.isSameDay(selectedDay, actualDate)
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
                      color: DateUtils.isSameDay(selectedDay, actualDate)
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
                            DateUtils.isSameDay(selectedDay, actualDate)
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
