import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/components/no_budget.dart';
import 'package:spender/components/total_budget_card.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_state.dart';
import '../components/home_chart.dart';
import '../components/home_transactions.dart';
import '../components/year_picker_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(
            height: 40,
          ),
          Align(
              alignment: Alignment.center,
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  var width = MediaQuery.of(context).size.width;
                  if (state.currentFinancials != null) {
                    return Align(
                        child: SizedBox(
                            width: width * 0.8,
                            child: TotalBudgetCard(
                              financials: state.currentFinancials!,
                              backgroundImageWidth: width * 0.68,
                            )));
                  }
                  return const NoBudgetWidget();
                },
              )),
          const SizedBox(
            height: 60,
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Analytics (Amount Spent)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: _handleDialogPressed,
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: Text("Year-${state.analysisYear}"),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) => ChartWidget(
                    state: state,
                  )),
          const SizedBox(height: 20),
          const HomeTransactions()
        ],
      ),
    );
  }

  void _handleDialogPressed() async {
    var state = context.read<HomeBloc>().state;
    DateTime firstYear = state.firstEverRecordYear != null
        ? DateTime.utc(state.firstEverRecordYear!)
        : DateTime.now();
    var result = await showDialog(
        context: context,
        builder: (_) => YearPickerDialog(
              selectedDate: DateTime.utc(state.analysisYear),
              firstDate: firstYear,
              lastDate: DateTime.now(),
              onChange: (t) {
                Navigator.pop(context, t.year);
              },
            ));
    if (!mounted || result == null) return;
    context.read<HomeBloc>().add(HomeAnalysisDateChangeEvent(result));
  }
}
