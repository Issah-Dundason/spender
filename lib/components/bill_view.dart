import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/bill/billing_event.dart';
import 'package:spender/bloc/bill/billing_state.dart';
import 'package:spender/util/app_utils.dart';

import '../bloc/bill/bill_bloc.dart';
import '../model/bill_type.dart';
import '../model/expenditure.dart';

class BillView extends StatefulWidget {
  final List<BillType> billTypes;
  final Expenditure? expenditure;

  const BillView({Key? key, required this.billTypes, this.expenditure})
      : super(key: key);

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _billController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  BillType? _billType;
  PaymentType _paymentType = PaymentType.cash;
  Priority _priority = Priority.need;

  @override
  void initState() {
    _billController = TextEditingController(text: widget.expenditure?.bill);
    _descriptionController =
        TextEditingController(text: widget.expenditure?.description);
    _amountController = TextEditingController();

    if (widget.expenditure != null) {
      var amount = AppUtils.amountPresented(widget.expenditure!.price);
      _amountController.text = '$amount';
      _billType = widget.expenditure!.type;
      _paymentType = widget.expenditure!.paymentType;
      _priority = widget.expenditure!.priority;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: BlocConsumer<BillBloc, BillingState>(
        listener: (bloc, state) {
          if (state.processingState == ProcessingState.done) {
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //bar
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12)),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 24, right: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: _billController,
                                validator: (s) {
                                  if (s != null && s.isEmpty) {
                                    return 'Field can not be empty';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                decoration: const InputDecoration(
                                    hintText: "bill name"),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: _ProductTypeDropDown<BillType>(
                              onChange: (t) => setState(() => _billType = t),
                              value: _billType,
                              title: "Bill Type",
                              items: widget.billTypes,
                              menuItemBuilder: (t) => Text(t.name),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: _amountController,
                                validator: (s) {
                                  if (s != null && s.isEmpty) {
                                    return 'Field can not be empty';
                                  }
                                  if(double.parse(s!) < 1) return '0 is not allowed';
                                  return null;
                                },
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'))
                                ],
                                decoration: const InputDecoration(
                                    hintText: "amount paid"),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: _ProductTypeDropDown<PaymentType>(
                              value: _paymentType,
                              onChange: (t) =>
                                  setState(() => _paymentType = t!),
                              title: "Payment Type",
                              menuItemBuilder: (t) => Text(
                                t.name,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                              items: PaymentType.values,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 4,
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                minLines: 2,
                                maxLines: 4,
                                controller: _descriptionController,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(120),
                                ],
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                    hintText: "description"),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: _ProductTypeDropDown<Priority>(
                              value: _priority,
                              onChange: (t) => setState(() => _priority = t!),
                              title: "Priority",
                              menuItemBuilder: (t) => Text(t.name),
                              items: Priority.values,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      state.processingState == ProcessingState.pending
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                bool? isValid =
                                    _formKey.currentState?.validate();
                                if (isValid != null && !isValid) return;
                                if (_billType == null) {
                                  showErrorDialog(context);
                                  return;
                                }

                                widget.expenditure == null ? save() : update();
                              },
                              style: getButtonStyle(context),
                              child: Text(widget.expenditure == null
                                  ? "ADD"
                                  : "Update"))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void save() {
    var amount = AppUtils.getActualAmount(_amountController.value.text);
    var description = _descriptionController.value.text;
    var bill = _billController.value.text;
    Expenditure ex = Expenditure.latest(
        bill, description, _paymentType, _billType!, amount, _priority);
    context.read<BillBloc>().add(BillSaveEvent(ex));
  }

  void update() {
    var amount = AppUtils.getActualAmount(_amountController.value.text);
    var description = _descriptionController.value.text;
    var bill = _billController.value.text;
    Expenditure ex = Expenditure(widget.expenditure!.id, bill, description,
        _paymentType, _billType!, amount,widget.expenditure!.date,  _priority);
    context.read<BillBloc>().add(BillUpdateEvent(ex));
  }

  ButtonStyle getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Error',
                textAlign: TextAlign.center,
              ),
              content: const Text('Bill type must be set',
                  textAlign: TextAlign.center),
            ));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _billController.dispose();
    super.dispose();
  }
}

class _ProductTypeDropDown<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? value;
  final Widget Function(T) menuItemBuilder;
  final void Function(T?)? onChange;

  const _ProductTypeDropDown(
      {Key? key,
      required this.title,
      this.items = const [],
      required this.menuItemBuilder,
      this.value,
      this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      //  mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        DropdownButton<T>(
          isExpanded: true,
          onChanged: (s) {
            if (onChange != null) onChange!(s);
          },
          alignment: AlignmentDirectional.bottomEnd,
          hint: const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text("----Select"),
          ),
          value: value,
          itemHeight: null,
          items: [
            ...items.map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: menuItemBuilder(e),
                ))
          ],
        )
      ],
    );
  }
}
