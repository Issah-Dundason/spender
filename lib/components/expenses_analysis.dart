import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../pages/pie_chart_page.dart';
import '../repository/expenditure_repo.dart';
import '../service/database.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<FilterOptions>(
                  value: _options,
                  underline: Container(),
                  items: FilterOptions.values
                      .map((e) => DropdownMenuItem<FilterOptions>(
                            value: e,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: showChart),
              const SizedBox(
                width: 20,
              ),
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
      ),
    );
  }

  void showPieChart() async {
    var repo = context.read<AppRepository>();
    late List<PieData> pieData;

    if (_options == FilterOptions.currentMonth) {
      String dbFormat = '\'%Y-%m\'';
      String date = DateFormat('yyyy-MM').format(DateTime.now());
      pieData = await repo.getPieData(dbFormat, date);
    }

    if (_options == FilterOptions.currentYear) {
      String dbFormat = '\'%Y\'';
      String date = '${DateTime.now().year}';
      pieData = await repo.getPieData(dbFormat, date);
    }

    if (_options == FilterOptions.lastYear) {
      String dbFormat = '\'%Y\'';
      String date = '${DateTime.now().year - 1}';
      pieData = await repo.getPieData(dbFormat, date);
    }

    if (_options == FilterOptions.overall) {
      pieData = await repo.getOverallPieData();
    }

    if(!mounted) return;

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PieChartPage(
                  pieData: pieData,
                )));
  }

  void showChart(FilterOptions? options) {
    if (options == null) return;
    setState(() => _options = options);
  }
}
