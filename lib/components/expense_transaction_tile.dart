import 'dart:ui';

import 'package:flutter/material.dart.';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/components/receipt.dart';
import '../bloc/bill/bill_bloc.dart';
import '../icons/icons.dart';
import '../model/expenditure.dart';
import '../repository/expenditure_repo.dart';
import '../theme/theme.dart';
import 'bill_view.dart';

class EditableTransactionTile extends StatefulWidget {
  final Color? tileColor;
  final Color? textColor;
  final Color? iconColor;

  const EditableTransactionTile(
      {Key? key,
      required this.expenditure,
      this.tileColor,
      this.textColor,
      this.iconColor})
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
      color: widget.tileColor ?? Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 14.0, left: 14.0, right: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overflow: TextOverflow.ellipsis,
                        'Bill: ${widget.expenditure.bill}',
                        style:
                            TextStyle(fontSize: 16, color: widget.textColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Price: ₵${NumberFormat().format(widget.expenditure.cash)}',
                          style: TextStyle(
                              fontSize: 16, color: widget.textColor)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Priority: ${widget.expenditure.priority.name.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.textColor,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Payment Type: ${widget.expenditure.paymentType.name}',
                          style: TextStyle(
                              fontSize: 16, color: widget.textColor)),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 14.0,
                right: 14.0,
                top: 4,
              ),
              child: Row(
                children: [
                  IconButton(
                      color: widget.iconColor ??
                          Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => Receipt(
                                  expenditure: widget.expenditure,
                                ));
                      },
                      icon: const Icon(ReceiptIcon.icon, size: 23)),
                  const SizedBox(
                    width: 12,
                  ),
                  IconButton(
                      color: widget.iconColor ??
                          Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        var result = await showDialog(
                            context: context,
                            builder: (_) => buildDeleteDialog(_));
                        if (result != true) return;
                        if (!mounted) return;
                        selfDestruct();
                      },
                      icon: const Icon(Bin.icon, size: 23)),
                  const SizedBox(
                    width: 12,
                  ),
                  IconButton(
                      color: widget.iconColor ??
                          Theme.of(context).colorScheme.primary,
                      onPressed: showUpdate,
                      icon: const Icon(
                        QuillPencil.icon,
                        size: 23,
                      )),
                ],
              ),
            ),
          ),
          Container(
            height: 10,
            color: Colors.black12,
          )
        ],
      ),
    );
  }

  void notifyBlocs() {
    context.read<ExpensesBloc>().add(const LoadEvent());
    context.read<HomeBloc>().add(const HomeInitializationEvent());
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

  void showUpdate() async {
    await _showAddBillView();
    notifyBlocs();
  }

  Future<dynamic> _showAddBillView() async {
    var appRepo = context.read<AppRepository>();
    var billTypes = await appRepo.getBillTypes();

    if (!mounted) return;

    return Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider(
            create: (_) {
              return BillBloc(appRepo: appRepo);
            },
            child: BillView(
              expenditure: widget.expenditure,
              billTypes: billTypes,
            ))));
  }

  void selfDestruct() async {
    var appRepository = context.read<AppRepository>();
    await appRepository.deleteRepository(widget.expenditure.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Deleted')));
    notifyBlocs();
  }
}
