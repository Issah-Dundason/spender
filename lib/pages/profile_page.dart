import 'package:flutter/material.dart';
import 'package:spender/components/update_budget.dart';

import '../components/avatar_change.dart';
import '../components/budget_year.dart';

class AppProfile extends StatefulWidget {
  const AppProfile({Key? key}) : super(key: key);

  @override
  State<AppProfile> createState() => _AppProfileState();
}

class _AppProfileState extends State<AppProfile> {
  @override
  Widget build(BuildContext context) {
    return (SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change your avatar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: AvatarChanger(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Current Month Budget',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const BudgetUpdate(),
                  const SizedBox(height: 50),
                  const TitleButtonComponent(
                      topTitle: "Budgets", buttonText: "Select Year"),
                  DataTable(columns: const [
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
                  ], rows: const [
                    DataRow(cells: [
                      DataCell(Text('10567')),
                      DataCell(Text('GHS200.00')),
                      DataCell(Text('4-Jan-2023')),
                    ]),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
