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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeInitializationEvent());
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocBuilder<HomeBloc, IHomeState>(
              builder: (context, state) {
                var width = MediaQuery.of(context).size.width;

                if (state is HomeLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                var currentState = state as HomeSuccessFetchState;

                return ListView(
                  children: [
                    const SizedBox(height: 20,),
                    if (state.currentFinancials != null)
                      Align(
                        child: SizedBox(
                            width: width * 0.8,
                            child: TotalBudgetCard(
                              financialsData: state.currentFinancials!,
                              backgroundImageWidth: width * 0.68,
                            )),
                      ),
                    if (state.currentFinancials == null) const NoBudgetWidget(),
                    const SizedBox(
                      height: 60,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Analytics (Amount Spent)",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        HomeYearBtn()
                      ],
                    ),
                    const SizedBox(height: 20),
                    ChartWidget(
                      monthExpenditures: currentState.monthExpenditures,
                    ),
                    const SizedBox(height: 20),
                    HomeTransactions(
                      bills: currentState.transactionsToday,
                    )
                  ],
                );
              },
            )),
      ),
    );
  }
}

class HomeYearBtn extends StatefulWidget {
  const HomeYearBtn({Key? key}) : super(key: key);

  @override
  State<HomeYearBtn> createState() => _HomeYearBtnState();
}

class _HomeYearBtnState extends State<HomeYearBtn> {
  late int year;

  @override
  void initState() {
    year = DateTime.now().year;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleDialogPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(08))),
      child: Text("Year-$year"),
    );
  }

  void _handleDialogPressed() async {
    var state = context.read<HomeBloc>().state as HomeSuccessFetchState;
    DateTime firstYear = state.firstEverRecordYear != null
        ? DateTime(state.firstEverRecordYear!)
        : DateTime.now();
    var result = await showDialog(
        context: context,
        builder: (_) => YearPickerDialog(
              selectedDate: DateTime(year),
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
