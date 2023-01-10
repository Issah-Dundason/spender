import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../repository/expenditure_repo.dart';

const optionsRep = ['Current Month', 'Current Year', 'Last Year', 'Overall'];

enum FilterOptions { currentMonth, currentYear, lastYear, overall }

extension on FilterOptions {
  get name => optionsRep[index];
}

class ExpenseAnalysisSection extends StatefulWidget {
  const ExpenseAnalysisSection({
    Key? key,
  }) : super(key: key);

  @override
  State<ExpenseAnalysisSection> createState() => _ExpenseAnalysisSectionState();
}

class _ExpenseAnalysisSectionState extends State<ExpenseAnalysisSection> {

  FilterOptions _options = FilterOptions.currentMonth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 18),
        ),
        // const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DropdownButton<FilterOptions>(
              value: _options,
                items: FilterOptions.values
                    .map((e) => DropdownMenuItem<FilterOptions>(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: showChart),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(0, 0),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: showPieChart,
                child: const Text('Look up'))
          ],
        )
      ],
    );
  }

  void showPieChart() async {
    var date = DateFormat('yyyy-MM').format(DateTime.now().subtract(Duration(hours: 10)));
    print('date: $date');
    var repo = context.read<AppRepository>();
    var data = await repo.getPieData('\'%Y-%m\'', date);
    print('${data.length}');
  }

  void showChart(FilterOptions? options) {
    if(options == null) return;
    setState(() => _options = options);
  }
}

class PieChartDialog extends StatelessWidget {
  const PieChartDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
