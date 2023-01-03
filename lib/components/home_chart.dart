import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../service/database.dart';

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 200,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return AspectRatio(
                aspectRatio: 5,
                child: BarChart(BarChartData(
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(
                      border: null,
                      show: false,
                    ),
                    titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(),
                        bottomTitles: AxisTitles( sideTitles: _getBottomTitle(context))),
                    barGroups: _chartGroups(_displayList(state.monthExpenditures), context))),
              );
            },
          ),
        ),
      ),
    );
  }

  List<MonthSpending> _displayList(List<MonthSpending> fromState) {
    var results = <MonthSpending>[];
    for(int i = 1; i <= 12; i++) {
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
    return monthSpendings.map((m) {
      Decimal decimal = Decimal.fromInt(m.amount);
      var r = decimal / Decimal.fromInt(100);
      return BarChartGroupData(
        barsSpace: 30,
          x: m.month, barRods: [
        BarChartRodData(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12), topLeft: Radius.circular(12)),
            toY: r.toDouble(),
            width: 50)
      ]);
    }).toList();
  }

  SideTitles _getBottomTitle(BuildContext context) {
    return SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
      String text = 'Dec';
      switch (value.toInt()) {
        case 1:
          text = 'Jan';
          break;
        case 2:
          text = 'Feb';
          break;
        case 3:
          text = 'Mar';
          break;
        case 4:
          text = 'Apr';
          break;
        case 5:
          text = 'May';
          break;
        case 6:
          text = 'Jun';
          break;
        case 7:
          text = 'Jul';
          break;
        case 8:
          text = 'Aug';
          break;
        case 9:
          text = 'Sep';
          break;
        case 10:
         text = 'Oct';
         break;
        case 11:
          text = 'Nov';
          break;
      }
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(text),
      );
    });
  }
}
