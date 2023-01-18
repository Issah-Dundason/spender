import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../icons/icons.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile(
      {super.key,
      this.icon = Cart.icon,
      this.store = "Puma Store",
      this.type = "Bank Amount",
      this.amount = 954,
      this.date = "Fri, 05 April 2022", required this.image});

  final IconData icon;
  final String store;
  final String type;
  final double amount;
  final String date;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey[200],
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: SvgPicture.asset('assets/images/bills/$image', width: 35, height: 35, fit: BoxFit.scaleDown,)),
        title: SizedBox(
          height: 25,
          child: Text(
            store,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
          ),
        ),
        subtitle: Text(type,
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₵${NumberFormat().format(amount)}",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              )
            ]),
      ),
    );
  }
}
