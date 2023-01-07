import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Align(
          alignment: Alignment.center,
          child:
              SizedBox(width: size.width * 0.9, child:  TransactionCalendar(selectedDay: DateTime.now(),)),
        )
      ],
    );
  }
}

class TransactionCalendar extends StatelessWidget {
  const TransactionCalendar({Key? key, required this.selectedDay}) : super(key: key);

  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFE9E9EB),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime.utc(200),
          lastDay: DateTime.utc(2030),
          calendarFormat: CalendarFormat.week,
          calendarBuilders: CalendarBuilders(defaultBuilder: _defaultBuilder),
          headerStyle:
              const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          calendarStyle: const CalendarStyle(
            isTodayHighlighted: false,
            outsideDaysVisible: false,
          ),
        ),
      ),
    );
  }

  Widget _defaultBuilder(
      BuildContext context, DateTime actualDate, DateTime focusDate) {
    return Container(
      width: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.secondary),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.2),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                actualDate.day.toString(),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
              const SizedBox(
                height: 3,
              ),
              CircleAvatar(
                radius: 5,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              )
            ],
          ),
        ),
      ),
    );
  }
}
