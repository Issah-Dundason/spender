import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/stats/statistics.dart';
import '../pages/pie_chart_page.dart';

const optionsRep = ['Current Month', 'Current Year', 'Last Year', 'Overall'];


class ExpenseAnalysisSection extends StatefulWidget {
  const ExpenseAnalysisSection({
    Key? key,
  }) : super(key: key);

  @override
  State<ExpenseAnalysisSection> createState() => _ExpenseAnalysisSectionState();
}

class _ExpenseAnalysisSectionState extends State<ExpenseAnalysisSection> {
  StatisticsFilterOption _options = StatisticsFilterOption.currentMonth;

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
              DropdownButton<StatisticsFilterOption>(
                  value: _options,
                  underline: Container(),
                  items: StatisticsFilterOption.values
                      .map((e) => DropdownMenuItem<StatisticsFilterOption>(
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
                      padding: const EdgeInsets.all(10),
                      minimumSize: const Size(0, 0),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(08))),
                  onPressed: showPieChart,
                  child: const Text('Look up'))
            ],
          )
        ],
      ),
    );
  }

  void showPieChart() async {
    if (!mounted) return;

    context.read<StatisticsBloc>().add(StatisticsFilterChangeEvent(_options));

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PieChartPage()),
    );
  }

  void showChart(StatisticsFilterOption? options) {
    if (options == null) return;
    setState(() => _options = options);
  }
}
