import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';

import '../components/expenses_analysis.dart';
import '../components/expenses_calendar.dart';
import '../components/expenses_transactions.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final PageController _pageController = PageController();
  int _pageCount = 0;
  late DateTime _startDate;

  @override
  void initState() {
    context.read<ExpensesBloc>().stream.listen((state) {
      var start = state.yearOfFirstInsert == null
          ? DateUtils.dateOnly(DateTime.now())
          : DateUtils.dateOnly(DateTime(state.yearOfFirstInsert!));

      var end =
          DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 365 * 7));

      int days = end.difference(start).inDays;

      var current =
          DateUtils.dateOnly(state.selectedDate).difference(start).inDays;

      setState(() {
        _pageCount = days + 1;
        _startDate = start;
        Future.delayed(Duration.zero, () {
          _pageController.jumpToPage(current);
        });
      });
    });
    super.initState();
  }

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
          children: [ExpenseAnalysisSection()],
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
        Expanded(
            child: PageView.builder(
          controller: _pageController,
          itemCount: _pageCount,
          onPageChanged: (i) {
            var nextDate = _startDate.add(Duration(days: i));
            var bloc = context.read<ExpensesBloc>();
            if (DateUtils.isSameDay(bloc.state.selectedDate, nextDate)) return;
            bloc.add(ChangeDateEvent(nextDate));
          },
          itemBuilder: (_, i) {
            return const Align(
                alignment: Alignment.center, child: ExpensesTransactions());
          },
        ))
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
