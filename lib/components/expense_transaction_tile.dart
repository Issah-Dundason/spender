import 'package:flutter/material.dart.';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import '../model/bill.dart';

class EditableTransactionTile extends StatefulWidget {
  final Color? tileColor;
  final Color? textColor;
  final Color? iconColor;
  final Bill bill;
  final double imageSize;
  final double textSize;

  const EditableTransactionTile({
    Key? key,
    required this.bill,
    this.tileColor = const Color(0xFFB5A7B8),
    this.textColor = const Color(0xFFFFFFFF),
    this.iconColor = const Color(0xFFFFFFFF),
    this.imageSize = 45,
    this.textSize = 16
  }) : super(key: key);

  @override
  State<EditableTransactionTile> createState() =>
      _EditableTransactionTileState();
}

class _EditableTransactionTileState extends State<EditableTransactionTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.tileColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(09),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
              right: 20,
              bottom: 12,
              child: RichText(
                textWidthBasis: TextWidthBasis.longestLine,
                text: TextSpan(
                    text: '₵',
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        fontSize: 17,
                        color: Theme.of(context).colorScheme.secondary),
                    children: [
                      TextSpan(
                        text: NumberFormat.compact().format(widget.bill.cash),
                        style: const TextStyle(
                            fontSize: 17, color: Colors.black),
                      )
                    ]),
              )),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/bills/${widget.bill.type.image}',
                    fit: BoxFit.scaleDown,
                    width: widget.imageSize,
                    height: widget.imageSize,
                  ),
                ),
                const SizedBox(
                  width: 17,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          overflow: TextOverflow.clip,
                          widget.bill.title,
                          style: TextStyle(
                              fontSize: widget.textSize, color: widget.textColor),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        overflow: TextOverflow.clip,
                        widget.bill.formattedDate,
                        style:
                            TextStyle(fontSize: widget.textSize, color: widget.textColor),
                      ),
                      Visibility(
                          visible: widget.bill.isRecurring,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.repeat_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    toBeginningOfSentenceCase(
                                        widget.bill.pattern.name) as String,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  DateTime.parse(widget.bill.paymentDateTime)
                                          .isAfter(DateTime.now())
                                      ? Row(
                                          children: [
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: Colors.limeAccent),
                                                child:
                                                    const Text('Pending >>')),
                                          ],
                                        )
                                      : Container()
                                ],
                              )
                            ],
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              right: 10,
              top: 5,
              child: GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 30,),
              )),
        ],
      ),
    );
  }

  AlertDialog buildDeleteDialog({String? message}) {
    return AlertDialog(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Text(
        message ?? 'Do you want to delete it?',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, DeleteMethod.multiple);
            },
            child:  Text('Yes', style: TextStyle(color:Theme.of(context).colorScheme.primary),)),
        TextButton(
            onPressed: () {
              Navigator.pop(context, DeleteMethod.single);
            },
            child:  Text('No', style: TextStyle(color:Theme.of(context).colorScheme.primary)))
      ],
    );
  }

  void onDelete() async {
    var isRecurring = widget.bill.isRecurring;

    if (isRecurring && !widget.bill.isLast) {
      var ans = await showDialog(
          context: context,
          builder: (_) =>
              buildDeleteDialog(message: 'Should delete future events?'));

      if (ans == null || !mounted) return;
      var event = BillDeleteEvent(method: ans, bill: widget.bill);

      context.read<ExpensesBloc>().add(event);
      return;
    }

    var ans =
        await showDialog(context: context, builder: (_) => buildDeleteDialog());

    if (ans == null || ans == DeleteMethod.single || !mounted) return;

    context.read<ExpensesBloc>().add(BillDeleteEvent(bill: widget.bill));
  }
}
