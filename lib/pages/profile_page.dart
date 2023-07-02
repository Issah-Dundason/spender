import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        child: _ProfileView(
          showAppbar: showAppbar,
        ));
  }
}

class _ProfileView extends StatefulWidget {
  final bool showAppbar;

  const _ProfileView({Key? key, this.showAppbar = true}) : super(key: key);

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppbar
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              elevation: 0,
              foregroundColor: Colors.black,
              title: const Text('Profile'),
              centerTitle: true,
            )
          : null,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocListener<BudgetReviewBloc, IBudgetDataState>(
        listener: (context, state) {
          if (state is BudgetSavedState) {
            _showSnackWithMessage("Done");
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: BudgetUpdate(),
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
                    BlocBuilder<BudgetReviewBloc, IBudgetDataState>(
                      builder: (context, state) {
                        if (state is! BudgetDataFetchedState) {
                          return const SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator());
                        }

                        return ElevatedButton(
                          onPressed: () => _onYearButtonClicked(),
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

  void _showSnackWithMessage(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  void _onYearButtonClicked() async {
    var budgetBloc = context.read<BudgetReviewBloc>();
    var state = budgetBloc.state as BudgetDataFetchedState;

    var first = (state).firstYearOfBudgetEntry;
    var selectedDate = state.selectedYear;

    var year = await showDialog(
      context: context,
      builder: (_) => YearPickerDialog(
          selectedDate: DateTime(selectedDate),
          firstDate: first == null ? DateTime.now() : DateTime(first),
          onChange: (s) => Navigator.pop(_, s.year),
          lastDate: DateTime.now()),
    );

    if (year == null || !mounted) {
      return;
    }

    budgetBloc.add(YearBudgetEvent(year: year));
  }
}
