import 'package:flutter/material.dart.';

import 'package:intl/intl.dart';
import '../model/expenditure.dart';

class EditableTransactionTile extends StatelessWidget {
  const EditableTransactionTile({Key? key, required this.expenditure})
      : super(key: key);

  final Expenditure expenditure;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bill: ${expenditure.bill}'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Price: ${NumberFormat().format(expenditure.cash)}'),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Priority: ${expenditure.priority.name.toUpperCase()}'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Payment Type: ${expenditure.paymentType.name}'),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                TextButton(
                    style: buildButtonStyle(),
                    onPressed: () {},
                    child: const Text('View')),
                const SizedBox(
                  width: 12,
                ),
                TextButton(
                    style: buildButtonStyle(),
                    onPressed: () {},
                    child: const Text('Delete')),
                const SizedBox(
                  width: 12,
                ),
                TextButton(
                    style: buildButtonStyle(),
                    onPressed: () {},
                    child: const Text('update')),
              ],
            )
          ],
        ),
      ),
    );
  }

  ButtonStyle buildButtonStyle() {
    return TextButton.styleFrom(
        minimumSize: const Size(0, 0),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
  }
}
