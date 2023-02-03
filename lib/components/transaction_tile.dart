import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';


class TransactionTile extends StatelessWidget {
  const TransactionTile(
      {super.key,
      this.bill = "Puma Store",
      this.type = "Bank Amount",
      this.amount = 954,
      this.date = "Fri, 05 April 2022", required this.image});

  final String bill;
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
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SvgPicture.asset(
                  'assets/images/bills/$image',
                  fit: BoxFit.scaleDown,
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          bill,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        type,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      )
                    ]),
              ),

              Expanded(
                child: Column(
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
                      const SizedBox(height: 5,),
                      Text(
                        date,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      )
                    ]),
              )
            ],
        ),
      )
    );
  }
}