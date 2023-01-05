import 'package:flutter/material.dart';

import '../icons/icons.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile(
      {super.key,
      this.icon = Cart.icon,
      this.store = "Puma Store",
      this.type = "Bank Amount",
      this.amount = '954',
      this.date = "Fri, 05 April 2022"});

  final IconData icon;
  final String store;
  final String type;
  final String amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey[200],
      child: ListTile(
        leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              icon,
              size: 35,
              color: Colors.black,
            )),
        title: Text(
          store,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(type,
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₵$amount",
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
