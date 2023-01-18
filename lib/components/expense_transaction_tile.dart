import 'dart:ui';

import 'package:flutter/material.dart.';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      this.tileColor = const Color(0xFFB5A7B8),
      this.textColor = const Color(0xFFFFFFFF),
      this.iconColor = const Color(0xFFFFFFFF)})
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
      color: widget.tileColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(09),
          ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: showUpdate,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              right: 3,
                child: IconButton(icon:  Icon(Icons.close, color: widget.iconColor,), onPressed: () async {
              var result = await showDialog(
                  context: context,
                  builder: (_) => buildDeleteDialog(_));
              if (result != true) return;
              if (!mounted) return;
              selfDestruct();
            },)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/bills/${widget.expenditure.type.image}',
                    fit: BoxFit.scaleDown,
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          overflow: TextOverflow.clip,
                          'Bill: ${widget.expenditure.bill}',
                          style: TextStyle(fontSize: 16, color: widget.textColor),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                overflow: TextOverflow.clip,
                                widget.expenditure.formattedDate,
                                style:
                                    TextStyle(fontSize: 16, color: widget.textColor),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '₵${NumberFormat().format(widget.expenditure.cash)}',
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: widget.textColor),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        'Do you want to delete it?',
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
