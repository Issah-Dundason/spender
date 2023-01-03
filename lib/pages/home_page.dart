import 'package:flutter/material.dart';
import 'package:spender/components/no_budget.dart';

import '../components/home_chart.dart';
import '../components/home_transactions.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView(
        children: [
          const SizedBox(
            height: 40,
          ),
          const Align(alignment: Alignment.center, child: NoBudgetWidget()),
          const SizedBox(
            height: 60,
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                const Text("Analytics (Amount Spent)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                ElevatedButton(onPressed: () {}, child: Text("Year-2022"), style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),)
              ],),
            ),
          ),
          const SizedBox(height: 20),
          const ChartWidget(),
          const SizedBox(height: 20),
          const HomeTransactions()
        ],
      ),
    );
  }
}
