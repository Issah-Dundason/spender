import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spender/service/database.dart';
import 'package:spender/util/app_utils.dart';

class TotalBudgetCard extends StatelessWidget {
  final double backgroundImageWidth;

  final Financials financials;

  const TotalBudgetCard(
      {super.key, required this.financials, this.backgroundImageWidth = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 5,
            child: Container(
              width: backgroundImageWidth,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(30)),
              height: 100,
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: const Alignment(0.8, 1),
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary
                      ])),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Current Month Budget: ",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 9,
                        ),
                        Text("Ȼ ${AppUtils.amountPresented(financials.budget)}",
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Balance: ",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                        Text(
                          "Ȼ ${AppUtils.amountPresented(financials.balance)}",
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
