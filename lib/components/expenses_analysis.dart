import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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

    if (_options == FilterOptions.overall) {}

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PieChartDialog(
                  pieData: pieData,
                )));
  }

  void showChart(FilterOptions? options) {
    if (options == null) return;
    setState(() => _options = options);
  }
}

class PieChartDialog extends StatelessWidget {
  final List<PieData> pieData;

  const PieChartDialog({Key? key, required this.pieData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var prime = Theme.of(context).colorScheme.primary;
    int i = 0;
    var colors = [const Color(0xFF524F5F), prime, const Color(0xFFF45737)];
    var size = MediaQuery.of(context).size;
    var sum = pieData.fold(
        0, (previousValue, element) => previousValue + element.amount);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Analysis'),
        foregroundColor: Colors.black,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        child: pieData.isEmpty
            ? const Center(
                child: Text(
                'No Available data',
                style: TextStyle(fontSize: 20),
              ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 124,
                  ),
                  SizedBox(
                    width: size.width * 0.35,
                    height: size.width * 0.35,
                    child: PieChart(PieChartData(
                        centerSpaceRadius: 60,
                     // centerSpaceColor: Colors.yellow,
                        sectionsSpace: 0,
                        sections: [
                          ...pieData.map(
                            (e) => PieChartSectionData(
                                // title:
                                //     '${e.billType.name} (${((e.amount / sum) * 100).floor()}%)',
                                value: e.amount.toDouble(),
                                showTitle: false,
                                badgePositionPercentageOffset: 1.7,
                                badgeWidget: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${((e.amount / sum) * 100).round()}%', style: TextStyle(),),
                                    Text(e.billType.name)
                                  ],
                                ),
                                radius: size.width * 0.15,
                                // titleStyle: const TextStyle(
                                //     color: Colors.white,
                                //     fontSize: 20,
                                //     fontWeight: FontWeight.w700),
                                color: colors[i++ % 2]),
                          )
                        ])),
                  ),
                ],
              ),
      ),
    );
  }
}
