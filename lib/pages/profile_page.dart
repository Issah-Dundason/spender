import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/budget/amount_cubit.dart';
import 'package:spender/bloc/budget/budget_review_bloc.dart';
import 'package:spender/bloc/budget/budget_review_event.dart';
import 'package:spender/components/update_budget.dart';
import 'package:spender/components/year_picker_dialog.dart';
import 'package:spender/repository/expenditure_repo.dart';

import '../bloc/budget/budget_review_state.dart';
import '../components/avatar_change.dart';
import '../components/budget_table.dart';

class AppProfile extends StatelessWidget {
  final bool showAppbar;

  const AppProfile({Key? key, this.showAppbar = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BudgetReviewBloc>(
        lazy: true,
        create: (_) => BudgetReviewBloc(appRepo: context.read<AppRepository>())
          ..add(InitializeEvent()),
        child:  _ProfileView(showAppbar: showAppbar,));
  }
}

class _ProfileView extends StatefulWidget {
  final bool showAppbar;

  const _ProfileView({
    Key? key,
    this.showAppbar = true
  }) : super(key: key);

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppbar ? AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Profile'),
        centerTitle: true,
      ): null,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocListener<BudgetReviewBloc, BudgetReviewState>(
        listener: (context, state) {
          var stat = state.budgetingState;
          if (stat == BudgetingStat.done) _handleDone("Done");

          if (stat == BudgetingStat.error) _handleDone("error");
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text(
                  'Change your avatar',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24, top: 20),
                child: AvatarChanger(),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 24, top: 24),
                child: Text(
                  'Current Month Budget',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: BlocProvider(
                  create: (context) =>
                      AmountCubit(context.read<AppRepository>())..initialize(),
                  child: const BudgetUpdate(),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Budget',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    BlocBuilder<BudgetReviewBloc, BudgetReviewState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: () => _onYearChange(),
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text('Year-${state.selectedYear}'),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: BudgetTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDone(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  void _onYearChange() async {
    var budgetBloc = context.read<BudgetReviewBloc>();
    var first = budgetBloc.state.firstYearOfBudgetEntry;
    var selectedDate = budgetBloc.state.selectedYear;
    var year = await showDialog(
        context: context,
        builder: (_) => YearPickerDialog(
            selectedDate: DateTime(selectedDate),
            firstDate: first == null ? DateTime.now() : DateTime(first),
            onChange: (s) => Navigator.pop(_, s.year),
            lastDate: DateTime.now()));

    if (year == null || !mounted) return;
    budgetBloc.add(YearBudgetEvent(year: year));
  }
}
