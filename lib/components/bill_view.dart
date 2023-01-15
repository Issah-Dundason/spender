import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/bill/billing_event.dart';
import 'package:spender/bloc/bill/billing_state.dart';
import 'package:spender/util/app_utils.dart';

import '../bloc/bill/bill_bloc.dart';
import '../model/bill_type.dart';
import '../model/expenditure.dart';
import '../util/calculation.dart';
import 'custom_key_pad.dart';

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

  var calculator = Calculator();

  BillType? _billType;
  PaymentType _paymentType = PaymentType.cash;
  Priority _priority = Priority.need;

  bool _showKeypad = false;

  @override
  void initState() {
    _billController = TextEditingController(text: widget.expenditure?.bill);
    _descriptionController =
        TextEditingController(text: widget.expenditure?.description);
    _amountController = TextEditingController();

    if (widget.expenditure != null) {
      var amount = AppUtils.amountPresented(widget.expenditure!.price);
      _amountController.text = '$amount';
      calculator.add('$amount');
      _billType = widget.expenditure!.type;
      _paymentType = widget.expenditure!.paymentType;
      _priority = widget.expenditure!.priority;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.4;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bill'),
        foregroundColor: Colors.black,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Stack(
        children: [
          BlocConsumer<BillBloc, BillingState>(
            listener: (bloc, state) {
              if (state.processingState == ProcessingState.done) {
                Navigator.pop(context, true);
              }
            },
            builder: (context, state) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideKeypad,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                flex: 4,
                                child: TextFormField(
                                  controller: _billController,
                                  onTap: _hideKeypad,
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
                                onTapped: _hideKeypad,
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
                                  onTap: () => setState(() => _showKeypad = true),
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 18),
                                  validator: (s) {
                                    if (s != null && s.isEmpty) {
                                      return 'Field can not be empty';
                                    }
                                    if (double.parse(s!) < 1) {
                                      return '0 is not allowed';
                                    }
                                    return null;
                                  },
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
                                onTapped: _hideKeypad,
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
                                  onTap: _hideKeypad,
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
                                onTapped: _hideKeypad,
                                value: _priority,
                                onChange: (t) => setState(() => _priority = t!),
                                title: "Priority",
                                menuItemBuilder: (t) => Text(t.name),
                                items: Priority.values,
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                        state.processingState == ProcessingState.pending
                            ? const CircularProgressIndicator()
                            : Visibility(
                              visible: !_showKeypad,
                              child: ElevatedButton(
                                  onPressed: () {
                                    bool? isValid =
                                        _formKey.currentState?.validate();
                                    if (isValid != null && !isValid) return;
                                    if (_billType == null) {
                                      _showErrorDialog(context);
                                      return;
                                    }

                                    widget.expenditure == null ? _save() : _update();
                                  },
                                  style: _getButtonStyle(context),
                                  child: Text(widget.expenditure == null
                                      ? "ADD"
                                      : "Update")),
                            ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: _showKeypad,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Theme.of(context).colorScheme.background,
                  child: CustomKeys(height: height, width: width * 0.7, onKeyTapped: _onAmountChanged,)),
            ),
          )
        ],
      ),
    );
  }

  void _onAmountChanged(String input) {
    if(input == "=") {
      calculator.calculate();
    } else if(input == "<") {
      calculator.remove();
    } else if(input == "c") {
      calculator.clear();
    } else {
      calculator.add(input);
    }
    _amountController.text = calculator.getString();
  }

  void _save() {
    var amount = AppUtils.getActualAmount(_amountController.value.text);
    var description = _descriptionController.value.text;
    var bill = _billController.value.text;
    Expenditure ex = Expenditure.latest(
        bill, description, _paymentType, _billType!, amount, _priority);
    context.read<BillBloc>().add(BillSaveEvent(ex));
  }

  void _update() {
    var amount = AppUtils.getActualAmount(_amountController.value.text);
    var description = _descriptionController.value.text;
    var bill = _billController.value.text;
    Expenditure ex = Expenditure(widget.expenditure!.id, bill, description,
        _paymentType, _billType!, amount, widget.expenditure!.date, _priority);
    context.read<BillBloc>().add(BillUpdateEvent(ex));
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
  }

  void _showErrorDialog(BuildContext context) {
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

  void _hideKeypad() {
    if(_showKeypad) setState(() => _showKeypad = false);
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
  final Function()? onTapped;

  const _ProductTypeDropDown(
      {Key? key,
      required this.title,
      this.items = const [],
      required this.menuItemBuilder,
      this.value,
      this.onChange, this.onTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      //  mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        DropdownButton<T>(
          onTap: onTapped,
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
