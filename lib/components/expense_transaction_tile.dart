import 'dart:ui';

import 'package:flutter/material.dart.';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:spender/components/receipt.dart';
import '../bloc/bill/bill_bloc.dart';
import '../icons/icons.dart';
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
      color: Theme.of(context).colorScheme.primaryContainer,
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
                      Text(
                        'Bill: ${widget.expenditure.bill}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Price: ${NumberFormat().format(widget.expenditure.cash)}',
                          style: const TextStyle(fontSize: 15)),
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
                          'Priority: ${widget.expenditure.priority.name.toUpperCase()}',
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Payment Type: ${widget.expenditure.paymentType.name}',
                          style: const TextStyle(fontSize: 15)),
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
                  IconButton(
                      style: buildButtonStyle(),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => Receipt(
                                  expenditure: widget.expenditure,
                                ));
                      },
                      icon: const Icon(ReceiptIcon.receipt, size: 23)),
                  const SizedBox(
                    width: 12,
                  ),
                  IconButton(
                       style: buildButtonStyle(),
                      onPressed: () async {
                        var result = await showDialog(
                            context: context,
                            builder: (_) => buildDeleteDialog(_));
                        if (result != true) return;
                      },
                      icon: const Icon(Bin.bin, size: 23)),
                  const SizedBox(
                    width: 12,
                  ),
                  IconButton(
                     style: buildButtonStyle(),
                      onPressed: () {
                        showUpdate();
                      },
                      icon: const Icon(QuillPencil.quill2, size: 23,)),
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
    return IconButton.styleFrom(
        minimumSize: const Size(0, 10),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
  }
}
