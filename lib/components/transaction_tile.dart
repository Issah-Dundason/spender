import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile(
      {super.key,
      this.store = "Puma Store",
      this.type = "Bank Amount",
      this.amount = 954,
      this.date = "Fri, 05 April 2022"});

  final String store;
  final String type;
  final int amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 100,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.grey[100],
        child: ListTile(
          leading: Icon(Icons.image),
          title: Text(
            store,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(type),
          trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$$amount",
                  style: TextStyle(color: Colors.green, fontSize: 24),
                ),
                Text(date)
              ]),
        ),
      ),
    );
  }
}
