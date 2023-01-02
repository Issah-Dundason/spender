import 'package:flutter/material.dart';
import 'package:spender/components/no_budget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ListView(
      children: [
        SizedBox(height: 30,),
        Align(
          alignment: Alignment.center,
            child: NoBudgetWidget())
      ],
    ),);
  }
}
