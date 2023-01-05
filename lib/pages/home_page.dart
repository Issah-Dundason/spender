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
          TitleButtonComponent(
              topTitle: "Analytics (Amount Spent)", buttonText: "Year-2022"),
          const SizedBox(height: 20),
          const ChartWidget(),
          const SizedBox(height: 20),
          const HomeTransactions()
        ],
      ),
    );
  }
}

class TitleButtonComponent extends StatelessWidget {
  final String topTitle;
  final String buttonText;

  const TitleButtonComponent({
    Key? key,
    required this.topTitle,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            topTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(buttonText),
            style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }
}
