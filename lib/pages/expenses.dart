import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';

import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../components/expenses_analysis.dart';
import '../components/expenses_calendar.dart';
import '../components/expenses_transactions.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocListener<ExpensesBloc, IExpensesState>(
      listener: (context, state) {
        if (state is ExpensesDeletedState) {
          context.read<HomeBloc>().add(const HomeInitializationEvent());
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('deleted!')));
        }
      },
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
                width: size.width * 0.9, child: const TransactionCalendar()),
          ),
          const ExpansionTile(
            title: Text('Statistics'),
            children: [ExpenseAnalysisSection()],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
                width: size.width * 0.9,
                child: BlocBuilder<ExpensesBloc, IExpensesState>(
                    builder: (context, state) {
                  if (state is! ExpensesSuccessfulState) {
                    return const Text("...");
                  }

                  var date =
                      DateFormat("yyyy-MM-dd").format(state.selectedDate);

                  return Text('Transactions on $date',
                      style: const TextStyle(fontSize: 16));
                })),
          ),
          const SizedBox(height: 10),
          Expanded(
              child: Draggable(
                axis: Axis.horizontal,
            feedback:  Material(child: SizedBox( height: size.height * 0.5, child: const ExpensesTransactions())),
            childWhenDragging: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.keyboard_double_arrow_left, size: 24,),
                Icon(Icons.keyboard_double_arrow_right, size: 24,),
              ],
            ),
            child: const ExpensesTransactions(),
            onDragEnd: (drag) {
              var bloc = context.read<ExpensesBloc>();
              var state = bloc.state as ExpensesSuccessfulState;

              var changeInX = drag.velocity.pixelsPerSecond.dx;

              if(changeInX < 0) {
                var newDate = DateUtils.dateOnly((state).selectedDate).add(const Duration(days: 1));
                bloc.add(ExpensesDateChangeEvent(newDate));
              }

              if(changeInX > (size.width / 2)) {
                var newDate = DateUtils.dateOnly((state).selectedDate).subtract(const Duration(days: 1));
                bloc.add(ExpensesDateChangeEvent(newDate));
              }

            },
          ))
        ],
      ),
    );
  }
}
