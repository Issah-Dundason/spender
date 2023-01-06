import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:spender/util/app_utils.dart';

import '../bloc/home/home_state.dart';
import '../service/database.dart';

class ChartWidget extends StatefulWidget {
  final HomeState state;

  const ChartWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  ScrollController scrollController = ScrollController();

  void _scrollToRightPosition() async {
    await Future.value();

    int month = 1;
    if (widget.state.monthExpenditures.isNotEmpty) {
      month = widget.state.monthExpenditures.last.month;
    }

    var maxScroll = scrollController.position.maxScrollExtent;
    var scrollPos = (((month - 1) * (maxScroll - 0)) / (11));
    scrollController.jumpTo(scrollPos);
  }

  @override
  Widget build(BuildContext context) {
    _scrollToRightPosition();
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 200,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: AspectRatio(
            aspectRatio: 5,
            child: BarChart(BarChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(
                  border: null,
                  show: false,
                ),
                titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(),
                    topTitles: AxisTitles(
                        sideTitles: _topTitle(context,
                            _displayList(widget.state.monthExpenditures))),
                    bottomTitles:
                        AxisTitles(sideTitles: _getBottomTitle(context))),
                barGroups: _chartGroups(
                    _displayList(widget.state.monthExpenditures), context))),
          ),
        ),
      ),
    );
  }

  List<MonthSpending> _displayList(List<MonthSpending> fromState) {
    var results = <MonthSpending>[];
    for (int i = 1; i <= 12; i++) {
      try {
        var m = fromState.firstWhere((e) => e.month == i);
        results.add(m);
      } on StateError {
        results.add(MonthSpending(i, 0));
      }
    }
    return results;
  }

  List<BarChartGroupData> _chartGroups(
      List<MonthSpending> monthSpendings, BuildContext context) {
    var month = DateTime.now().month;
    return monthSpendings.map((m) {
      var r = AppUtils.amountPresented(m.amount);
      return BarChartGroupData(barsSpace: 30, x: m.month, barRods: [
        BarChartRodData(
            color: month == m.month
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.tertiary,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12), topLeft: Radius.circular(12)),
            toY: r,
            width: 50)
      ]);
    }).toList();
  }

  SideTitles _topTitle(
      BuildContext context, List<MonthSpending> monthSpendings) {
    return SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          var month = DateTime.now().month;
          var ms = monthSpendings.firstWhere((m) => m.month == value.toInt());
          var r = AppUtils.amountPresented(ms.amount);
          return Text('₵$r',
              style: TextStyle(
                color: value.toInt() == month
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
              ));
        });
  }

  SideTitles _getBottomTitle(BuildContext context) {
    var month = DateTime.now().month;
    var currentMonth = 12;
    return SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = 'Dec';
          switch (value.toInt()) {
            case 1:
              text = 'Jan';
              currentMonth = 1;
              break;
            case 2:
              text = 'Feb';
              currentMonth = 2;
              break;
            case 3:
              text = 'Mar';
              currentMonth = 3;
              break;
            case 4:
              text = 'Apr';
              currentMonth = 4;
              break;
            case 5:
              text = 'May';
              currentMonth = 5;
              break;
            case 6:
              text = 'Jun';
              currentMonth = 6;
              break;
            case 7:
              text = 'Jul';
              currentMonth = 7;
              break;
            case 8:
              text = 'Aug';
              currentMonth = 8;
              break;
            case 9:
              text = 'Sep';
              currentMonth = 9;
              break;
            case 10:
              text = 'Oct';
              currentMonth = 10;
              break;
            case 11:
              text = 'Nov';
              currentMonth = 11;
              break;
          }
          return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                text,
                style: TextStyle(
                  color: month == currentMonth
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary,
                ),
              ));
        });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
