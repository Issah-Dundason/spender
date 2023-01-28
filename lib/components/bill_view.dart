import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/bill/billing_event.dart';
import 'package:spender/bloc/bill/billing_state.dart';
import 'package:spender/util/app_utils.dart';

import '../bloc/bill/bill_bloc.dart';
import '../model/bill_type.dart';
import '../model/bill.dart';
import '../util/calculation.dart';
import 'custom_key_pad.dart';

class BillView extends StatefulWidget {
  final List<BillType> billTypes;
  final Bill? bill;

  const BillView({Key? key, required this.billTypes, this.bill})
      : super(key: key);

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _billController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  var _selectedRecurrence = Pattern.once;

  var _selectedDate = DateTime.now();
  var _selectedTime = TimeOfDay.now();
  late DateTime _endDate;

  final _calculator = Calculator();

  BillType? _billType;
  PaymentType _paymentType = PaymentType.cash;
  Priority _priority = Priority.need;

  bool _showKeypad = false;

  @override
  void initState() {
    _endDate = _selectedDate.add(const Duration(days: 365));
    _billController = TextEditingController(text: widget.bill?.title);
    _descriptionController =
        TextEditingController(text: widget.bill?.description);
    _amountController = TextEditingController();

    if (widget.bill != null) {
      var amount = AppUtils.amountPresented(widget.bill!.amount);
      _amountController.text = '$amount';
      _calculator.add('$amount');
      _billType = widget.bill!.type;
      _paymentType = widget.bill!.paymentType;
      _priority = widget.bill!.priority;
      _selectedRecurrence = widget.bill!.pattern;
      _selectedDate = DateTime.parse(widget.bill!.paymentDateTime);
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
      _endDate = widget.bill!.endDate != null
          ? DateTime.parse(widget.bill!.endDate!)
          : _endDate;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var keysHeight = MediaQuery.of(context).size.height * 0.4;
    var bodyHeight = height - 82;
    if (height >= 617) {
      bodyHeight = height - 110;
    }
    if (height < 617) {
      keysHeight = MediaQuery.of(context).size.height * 0.35;
    }
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
      body: WillPopScope(
        onWillPop: () async {
          if (!_showKeypad) return true;
          _hideKeypad();
          return false;
        },
        child: Stack(
          children: [
            BlocConsumer<BillBloc, BillingState>(
              listener: (bloc, state) {
                if (state.processingState == ProcessingState.done) {
                  _showSnackBar("Entry saved");
                  _clearContent();
                }
              },
              builder: (context, state) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideKeypad,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: bodyHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Date'),
                                      GestureDetector(
                                        onTap: _onDate,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              DateFormat('dd/MM/yy')
                                                  .format(_selectedDate),
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 5),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              padding: const EdgeInsets.all(5),
                                              child: const Icon(
                                                Icons.calendar_month,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Time'),
                                      GestureDetector(
                                        onTap: _onTime,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _selectedTime
                                                  .format(context)
                                                  .toLowerCase(),
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 5),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              padding: const EdgeInsets.all(5),
                                              child: const Icon(
                                                Icons.access_time_outlined,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 50,
                              ),
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
                                      onChange: (t) =>
                                          setState(() => _billType = t),
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
                                        onTap: () =>
                                            setState(() => _showKeypad = true),
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
                                      onChange: (t) =>
                                          setState(() => _priority = t!),
                                      title: "Priority",
                                      menuItemBuilder: (t) => Text(t.name),
                                      items: Priority.values,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text('Recurrence*'),
                              RadioListTile<Pattern>(
                                  title: const Text('Once'),
                                  value: Pattern.once,
                                  groupValue: _selectedRecurrence,
                                  onChanged: (value) => onRadio(value)),
                              RadioListTile<Pattern>(
                                  title: const Text('Daily'),
                                  value: Pattern.daily,
                                  groupValue: _selectedRecurrence,
                                  onChanged: (value) => onRadio(value)),
                              RadioListTile<Pattern>(
                                  title: const Text('Weekly'),
                                  value: Pattern.weekly,
                                  groupValue: _selectedRecurrence,
                                  onChanged: (value) => onRadio(value)),
                              RadioListTile<Pattern>(
                                  title: const Text('Monthly'),
                                  value: Pattern.monthly,
                                  groupValue: _selectedRecurrence,
                                  onChanged: (value) => onRadio(value)),
                              Visibility(
                                visible: _selectedRecurrence != Pattern.once,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('End Date:'),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: _onEndDate,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                DateFormat('dd/MM/yy')
                                                    .format(_endDate!),
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: const Icon(
                                                  Icons.calendar_month,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const Spacer(),
                              state.processingState == ProcessingState.pending
                                  ? const CircularProgressIndicator()
                                  : Visibility(
                                      visible: !_showKeypad,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            bool? isValid = _formKey
                                                .currentState
                                                ?.validate();
                                            if (isValid != null && !isValid)
                                              return;
                                            if (_billType == null) {
                                              _showErrorDialog(context);
                                              return;
                                            }

                                            widget.bill == null
                                                ? _save()
                                                : _update();
                                          },
                                          style: _getButtonStyle(context),
                                          child: Text(widget.bill == null
                                              ? "ADD"
                                              : "Update")),
                                    ),
                            ],
                          ),
                        ),
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
                    child: CustomKeys(
                      height: keysHeight,
                      width: width * 0.7,
                      onKeyTapped: _onAmountChanged,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onRadio(Pattern? value) {
    _hideKeypad();
    setState(() => _selectedRecurrence = value!);
  }

  void _onTime() async {
    _hideKeypad();
    var time =
        await showTimePicker(context: context, initialTime: _selectedTime);
    setState(() => _selectedTime = time ?? _selectedTime);
  }

  void _onDate() async {
    _hideKeypad();
    var date = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(199),
        lastDate: DateTime.now());
    setState(() => _selectedDate = date ?? _selectedDate);
  }

  void _onAmountChanged(String input) {
    if (input == "=") {
      _calculator.calculate();
    } else if (input == "<") {
      _calculator.remove();
    } else if (input == "c") {
      _calculator.clear();
    } else {
      _calculator.add(input);
    }
    _amountController.text = _calculator.getString();
  }

  void _save() {
    var amount = AppUtils.getActualAmount(_amountController.value.text);
    var description = _descriptionController.value.text;
    var title = _billController.value.text;
    var date = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedDate.minute);

    Bill bill;

    if(_selectedRecurrence != Pattern.once) {
      bill = Bill(
          title: title,
          description: description,
          paymentType: _paymentType,
          type: _billType!,
          paymentDateTime: date.toIso8601String(),
          amount: amount,
          isRecurring: true,
          priority: _priority,
          endDate: _endDate.toIso8601String(),
          pattern: _selectedRecurrence);
    } else {
      bill = Bill(
          title: title,
          description: description,
          paymentType: _paymentType,
          type: _billType!,
          paymentDateTime: date.toIso8601String(),
          amount: amount,
          priority: _priority,
          pattern: _selectedRecurrence);
    }
    context.read<BillBloc>().add(BillSaveEvent(bill));
  }

  void _update() {
    var amount = AppUtils.getActualAmount(_amountController.value.text);
    var description = _descriptionController.value.text;
    var bill = _billController.value.text;
    var date = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedDate.minute);
    // Bill ex = Bill(
    //     widget.expenditure!.id,
    //     bill,
    //     description,
    //     _paymentType,
    //     _billType!,
    //     amount,
    //     date.toIso8601String(),
    //     _priority);
    // context.read<BillBloc>().add(BillUpdateEvent(ex));
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
  }

  void _showErrorDialog(BuildContext context) async {
    await showDialog(
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

  void _clearContent() {
    _selectedTime = TimeOfDay.now();
    _selectedDate = DateTime.now();
    _amountController.text = '';
    _billController.text = '';
    _descriptionController.text = '';
    _billType = null;
    _paymentType = PaymentType.cash;
    _priority = Priority.need;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _hideKeypad() {
    if (!_showKeypad) return;
    _calculator.calculate();
    _amountController.text = _calculator.getString();
    setState(() => _showKeypad = false);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _billController.dispose();
    super.dispose();
  }

  void _onEndDate() async {
    var date = await showDatePicker(
        context: context,
        initialDate: _endDate!,
        firstDate: _selectedDate,
        lastDate: _selectedDate.add(const Duration(days: 365 * 7)));
    setState(() => _endDate = date ?? _endDate);
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
      this.onChange,
      this.onTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
