import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/bill/billing_event.dart';

import '../bloc/bill/bill_bloc.dart';
import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_event.dart';
import '../bloc/expenses/expenses_state.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../icons/icons.dart';
import '../model/bill.dart';
import '../pages/bill_view.dart';
import '../repository/expenditure_repo.dart';
import 'expense_transaction_tile.dart';

class ExpensesTransactions extends StatefulWidget {
  const ExpensesTransactions({Key? key}) : super(key: key);

  @override
  State<ExpensesTransactions> createState() => _ExpensesTransactionsState();
}

class _ExpensesTransactionsState extends State<ExpensesTransactions> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: BlocBuilder<ExpensesBloc, IExpensesState>(
        builder: (context, state) {

          if(state is! ExpensesSuccessfulState) {
            return const Center(child: CircularProgressIndicator(),);
          }


          if (state.transactions.isEmpty) {
            return const EmptyExpensesWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExpensesBloc>().add(const ExpensesLoadingEvent());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration:  BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24))),
              child: ListView(
                children: [
                  ...state.transactions.map((e) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => showUpdate(e),
                      child: EditableTransactionTile(
                        bill: e,
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        tileColor: Colors.grey[300],
                      ),
                    );
                  }).toList()
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showUpdate(Bill bill) async {
    await _showAddBillView(bill);
    notifyBlocs();
  }

  Future<dynamic> _showAddBillView(Bill bill) async {
    var appRepo = context.read<AppRepository>();

    if (!mounted) return;

    return Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider(
            create: (_) {
              return BillBloc(appRepo: appRepo)..add(BillInitializationEvent());
            },
            child: BillView(
              bill: bill,
            ))));
  }

  void notifyBlocs() {
    context.read<ExpensesBloc>().add(const ExpensesLoadingEvent());
    context.read<HomeBloc>().add(const HomeInitializationEvent());
  }
}

class EmptyExpensesWidget extends StatelessWidget {
  const EmptyExpensesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text("No Data"),
          Icon(
            Whiteboard.icon,
            size: 150,
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
    );
  }
}
