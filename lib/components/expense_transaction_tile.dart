import 'dart:ui';

import 'package:flutter/material.dart.';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:spender/components/receipt.dart';
import '../bloc/bill/bill_bloc.dart';
import '../model/expenditure.dart';
import '../repository/expenditure_repo.dart';
import '../theme/theme.dart';
import 'bill_view.dart';

class EditableTransactionTile extends StatefulWidget {
  const EditableTransactionTile({Key? key, required this.expenditure})
      : super(key: key);

  final Expenditure expenditure;

  @override
  State<EditableTransactionTile> createState() =>
      _EditableTransactionTileState();
}

class _EditableTransactionTileState extends State<EditableTransactionTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15),
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
                      Text(
                          'Price: ${NumberFormat().format(widget.expenditure.cash)}'),
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
                      Text(
                          'Payment Type: ${widget.expenditure.paymentType.name}'),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 14.0, right: 14.0, top: 14, bottom: 10),
              child: Row(
                children: [
                  TextButton(
                      style: buildButtonStyle(),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => Receipt(
                                  expenditure: widget.expenditure,
                                ));
                      },
                      child: const Text('view')),
                  const SizedBox(
                    width: 12,
                  ),
                  TextButton(
                      style: buildButtonStyle(),
                      onPressed: () async {
                        var result = await showDialog(
                            context: context,
                            builder: (_) => buildDeleteDialog(_));
                        if (result != true) return;
                      },
                      child: const Text('delete')),
                  const SizedBox(
                    width: 12,
                  ),
                  TextButton(
                      style: buildButtonStyle(),
                      onPressed: () {
                        showUpdate();
                      },
                      child: const Text('update')),
                ],
              ),
            ),
            Container(
              height: 10,
              color: Colors.black12,
            )
          ],
        ),
      ),
    );
  }

  AlertDialog buildDeleteDialog(BuildContext _) {
    return AlertDialog(
      content: const Text(
        'Are you sure?',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(_, true);
            },
            child: const Text('Yes')),
        TextButton(
            onPressed: () {
              Navigator.pop(_, false);
            },
            child: const Text('No'))
      ],
    );
  }

  Future<dynamic> showUpdate() async {
    var appRepo = context.read<AppRepository>();
    var billTypes = await appRepo.getBillTypes();
    return await showModalBottomSheet(
        isScrollControlled: true,
        shape: appBottomSheetShape,
        context: context,
        builder: (_) => BlocProvider(
              create: (_) {
                return BillBloc(appRepo: appRepo);
              },
              child: BillView(
                billTypes: billTypes,
                expenditure: widget.expenditure,
              ),
            ));
  }

  ButtonStyle buildButtonStyle() {
    return TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 16),
        minimumSize: const Size(0, 10),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
  }
}
