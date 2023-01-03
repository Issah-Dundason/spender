import 'package:flutter/material.dart';
import 'package:spender/icons/icons.dart';

class HomeTransactions extends StatelessWidget {
  const HomeTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Transactions",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        "View All",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary),
                      )),
                ],

              ),
              const _NoTransaction()
            ],
          ),
        ));
  }
}

class _NoTransaction extends StatelessWidget {
  const _NoTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Whiteboard.icon, size: 100, color: Theme.of(context).colorScheme.primary,),
        const Text('No transactions today', )
      ],
    );
  }
}
