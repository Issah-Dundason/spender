import 'package:flutter/material.dart.';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import '../bloc/bill/bill_bloc.dart';
import '../model/bill.dart';
import '../repository/expenditure_repo.dart';
import '../pages/bill_view.dart';

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

  final Bill expenditure;

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
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: widget.iconColor,
                  ),
                  onPressed: onDelete,
                )),
            Positioned(
                right: 20,
                bottom: 15,
                child: RichText(
                  textWidthBasis: TextWidthBasis.longestLine,
                  text: TextSpan(
                      text: '₵',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.secondary),
                      children: [
                        TextSpan(
                            text: NumberFormat.compact()
                                .format(widget.expenditure.cash),
                            style: const TextStyle(
                                fontSize: 17, color: Colors.black))
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
                      'assets/images/bills/${widget.expenditure.type.image}',
                      fit: BoxFit.scaleDown,
                      width: 40,
                      height: 40,
                    ),
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            overflow: TextOverflow.clip,
                            'Bill: ${widget.expenditure.title}',
                            style: TextStyle(
                                fontSize: 16, color: widget.textColor),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          overflow: TextOverflow.clip,
                          widget.expenditure.formattedDate,
                          style:
                              TextStyle(fontSize: 16, color: widget.textColor),
                        ),
                        Visibility(
                            visible: widget.expenditure.isRecurring,
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
                                              widget.expenditure.pattern.name)
                                          as String,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    DateTime.parse(widget
                                                .expenditure.paymentDateTime)
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
          ],
        ),
      ),
    );
  }

  void notifyBlocs() {
    context.read<ExpensesBloc>().add(const LoadEvent());
    context.read<HomeBloc>().add(const HomeInitializationEvent());
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
              Navigator.pop(context, true);
            },
            child: const Text('Yes')),
        TextButton(
            onPressed: () {
              Navigator.pop(context, false);
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
              bill: widget.expenditure,
              billTypes: billTypes,
            ))));
  }

  void onDelete() async {
    var isRecurring = widget.expenditure.isRecurring;
    if (isRecurring) {

      var ans = await showDialog(
          context: context,
          builder: (_) =>
              buildDeleteDialog(message: 'Should delete future events?'));

      if (ans == true) {
        if(!mounted) return;
        context.read<ExpensesBloc>().add(RecurrentDeleteEvent(
            bill: widget.expenditure, method: DeleteMethod.multiple));
      }

      if (ans == false) {
        if(!mounted) return;
        context.read<ExpensesBloc>().add(RecurrentDeleteEvent(
            bill: widget.expenditure));
      }

      return;
    }
    var ans =
        await showDialog(context: context, builder: (_) => buildDeleteDialog());
    if (ans != true) return;

    if(!mounted) return;
    context.read<ExpensesBloc>().add(NonRecurringDelete(widget.expenditure));
  }
}
