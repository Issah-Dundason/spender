import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/stats/statistics.dart';
import '../service/database.dart';
import '../util/app_utils.dart';

class PieChartPage extends StatelessWidget {
  const PieChartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Statistics'),
          foregroundColor: Colors.black,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: BlocBuilder<StatsBloc, StatState>(
          builder: (context, state) {

            if(state is Loading) {
              return const Center(child: CircularProgressIndicator(),);
            }

            var pieData = state.pieData;

            return StatChart(
              pieData: pieData,
            );
          },
        ));
  }
}

class StatChart extends StatelessWidget {
  final List<PieData> pieData;

  const StatChart({Key? key, required this.pieData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var prime = Theme.of(context).colorScheme.primary;

    int i = 0, k = 0;
    var colors = [
      const Color(0xFF524F5F),
      prime,
      const Color(0xFFF45737),
      const Color(0xFFFEBC68),
      const Color(0xFF1F9589),
      const Color(0xFF434247),
      const Color(0xFFFCDB8C)
    ];

    var size = MediaQuery.of(context).size;

    var infoBoxWidth = 0.9;

    var width = size.width;

    var boxWidth = width * 0.04;

    var circleRadius = 0.15;

    if(width > 600) {
      boxWidth = 20;
      infoBoxWidth = 0.6;
    }

    if(width > 770) {
      infoBoxWidth = 0.4;
    }


    if(width < 500) {
      circleRadius = 0.19;
      infoBoxWidth = 1;
    }


    var sum = pieData.fold(
        0, (previousValue, element) => previousValue + element.amount);

    return Container(
      child: pieData.isEmpty
          ? const Center(
          child: Text(
            'No Available data',
            style: TextStyle(fontSize: 20),
          ))
          : ListView(
        children: [
          const SizedBox(
            height: 124,
          ),
          AspectRatio(
            aspectRatio: 4,
            child: PieChart(PieChartData(
                centerSpaceRadius: 30,
                sectionsSpace: 0,
                sections: [
                  ...pieData.map(
                        (e) {
                          return PieChartSectionData(
                        value: e.amount.toDouble(),
                        showTitle: false,
                        badgeWidget: Text(
                          '${((e.amount / sum) * 100).toStringAsFixed(2)}%',
                          style:  const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold),
                        ),
                        radius: size.width * circleRadius,
                        color: colors[i++]);
                        },
                  )
                ])),
          ),
          const SizedBox(
            height: 120,
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: size.width * infoBoxWidth,
              child: Container(
                color: Colors.grey.shade200,
                child: Table(
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    ...pieData.map((e) => TableRow(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            e.billType.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 18),
                          ),
                          const Spacer(),
                          Container(width: boxWidth, height: boxWidth,color: colors[k++],)
                        ],
                      ),
                      Text('₵${AppUtils.amountPresented(e.amount)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 18))
                    ]))
                  ],
                ),

              ),
            ),
          ),
          const SizedBox(height: 23,)
        ],
      ),
    );
  }
}