import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:spender/components/no_budget.dart';

import '../components/home_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ListView(
      children: const [
         SizedBox(height: 30,),
         Align(
          alignment: Alignment.center,
            child: NoBudgetWidget()),
         SizedBox(height: 50,),
        ChartWidget()
      ],
    ),);
  }
}

