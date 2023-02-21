import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/app_utils.dart';

class WiderScreenHomeCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color textColor;

  const WiderScreenHomeCard(
      {Key? key,
        required this.title,
        required this.amount,
        this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(minWidth: 200),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
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
          children: [
            Text(
              '$title: ',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('₵ ${NumberFormat().format(AppUtils.amountPresented(amount))}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 16))
          ],
        ),
      ),
    );
  }
}