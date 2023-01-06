import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/budget/amount_cubit.dart';
import 'package:spender/bloc/budget/budget_bloc.dart';
import 'package:spender/bloc/budget/budget_event.dart';
import 'package:spender/components/update_budget.dart';
import 'package:spender/repository/expenditure_repo.dart';

import '../bloc/budget/budget_state.dart';
import '../components/avatar_change.dart';

class AppProfile extends StatelessWidget {
  const AppProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BudgetBloc>(
        lazy: true,
        create: (_) => BudgetBloc(appRepo: context.read<AppRepository>())
          ..add(InitializeEvent()),
        child: const ProfileView());
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocListener<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if(state.budgetingState == BudgetingStat.done) {
            _handleDone("Done", context);
          }
          if(state.budgetingState == BudgetingStat.error) {
            _handleDone("error", context);
          }
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Budget',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('Year-2022'),
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

  void _handleDone(String s, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }
}

class BudgetTable extends StatelessWidget {
  const BudgetTable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
  builder: (context, state) {
    return DataTable(columns: const [
      DataColumn(
        label: Expanded(
          child: Text(
            'ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Amount',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ], rows:  [
      ...state.budgets.map((b) {
        return DataRow(cells: [
          DataCell(Text('${b.id}')),
          DataCell(Text('GHS200.00')),
          DataCell(Text('4-Jan-2023')),
        ]);
      }).toList()
    ]);
  },
);
  }
}
