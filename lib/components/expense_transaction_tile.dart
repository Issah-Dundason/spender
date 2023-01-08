
import 'package:flutter/material.dart.';

import 'package:intl/intl.dart';
import 'package:spender/components/receipt.dart';
import '../model/expenditure.dart';

class EditableTransactionTile extends StatefulWidget {
  const EditableTransactionTile({Key? key, required this.expenditure})
      : super(key: key);

  final Expenditure expenditure;

  @override
  State<EditableTransactionTile> createState() => _EditableTransactionTileState();
}

class _EditableTransactionTileState extends State<EditableTransactionTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14.0, left: 14.0),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bill: ${widget.expenditure.bill}'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Price: ${NumberFormat().format(widget.expenditure.cash)}'),
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
                        'Priority: ${widget.expenditure.priority.name.toUpperCase()}'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Payment Type: ${widget.expenditure.paymentType.name}'),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 14, bottom: 10),
            child: Row(
              children: [
                TextButton(
                    style: buildButtonStyle(),
                    onPressed: () {
                      showDialog(context: context, builder: (_) => Receipt(expenditure: widget.expenditure,));
                    },
                    child: const Text('View')),
                const SizedBox(
                  width: 12,
                ),
                TextButton(
                    style: buildButtonStyle(),
                    onPressed: () async {
                      var result = await showDialog(context: context, builder: (_) => AlertDialog(
                        content:  const Text('Are you sure?', textAlign: TextAlign.center,),
                        actions: [
                          TextButton(onPressed: () {
                            Navigator.pop(context, true);
                          }, child: const Text('Yes')),
                          TextButton(onPressed: () {
                            Navigator.pop(context, false);
                          }, child: const Text('No'))
                        ],
                      ));
                      if(result != true) return;
                    },
                    child: const Text('Delete')),
                const SizedBox(
                  width: 12,
                ),
                TextButton(
                  style: buildButtonStyle(),
                  onPressed: () {},
                    child: const Text('update')),
              ],
            ),
          ),
          Container(height: 10, color: Colors.black12,)
        ],
      ),
    );
  }

  ButtonStyle buildButtonStyle() {
    return TextButton.styleFrom(
      textStyle: const TextStyle(fontSize: 16),
        minimumSize: const Size(0, 10),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
  }
}
