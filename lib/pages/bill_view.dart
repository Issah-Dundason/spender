import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/bill/billing_event.dart';
import 'package:spender/bloc/bill/billing_state.dart';
import 'package:spender/util/app_utils.dart';

import '../bloc/bill/bill_bloc.dart';
import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_event.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/stats/statistics.dart';
import '../components/product_dropdown.dart';
import '../model/bill_type.dart';
import '../model/bill.dart';
import '../util/calculation.dart';
import '../components/custom_key_pad.dart';

class BillView extends StatefulWidget {
  final bool showAppBar;

  const BillView({
    Key? key,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _billNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Pattern _selectedRecurrence = Pattern.once;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  BillType? _billType;
  PaymentType _paymentType = PaymentType.cash;
  Priority _priority = Priority.need;
  DateTime? _endDate;

  bool _showKeypad = false;
  late AnimationController _animController;

  Bill? toUpdate;
  List<BillType> billTypes = [];

  final _calculator = Calculator();

  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    var state = context.read<BillBloc>().state;
    billTypes = state.billTypes;

    if (state is BillUpdateState) {
      _showBillToUpdateData(state.bill);
    }

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    super.initState();
  }

  @override
  void didUpdateWidget(BillView oldWidget) {
    var state = context.read<BillBloc>().state;
    billTypes = state.billTypes;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    var keysHeight = deviceSize.height * 0.48;
    var calcWidth = deviceSize.width * 0.72;

    if (deviceSize.width > 449.5 && deviceSize.height > 449.5) {
      calcWidth = deviceSize.width * 0.5;
      keysHeight = deviceSize.height * 0.4;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: widget.showAppBar
          ? AppBar(
              centerTitle: true,
              title: const Text('Bill'),
              foregroundColor: Colors.black,
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.background,
            )
          : null,
      body: WillPopScope(
        onWillPop: () async {
          if (!_showKeypad) return true;
          _hideKeypad();
          return false;
        },
        child: Stack(
          children: [
            BlocListener<BillBloc, IBillingState>(
              listener: (bloc, state) {
                if (state is BillSavedState) {
                  context
                      .read<ExpensesBloc>()
                      .add(const ExpensesLoadingEvent());
                  context.read<HomeBloc>().add(const HomeInitializationEvent());
                  context
                      .read<StatisticsBloc>()
                      .add(const StatisticsInitializationEvent());
                  _showSnackBar("Entry saved");
                  _clearContent();
                }

                if (state is BillUpdatedState) {
                  context
                      .read<ExpensesBloc>()
                      .add(const ExpensesLoadingEvent());
                  context.read<HomeBloc>().add(const HomeInitializationEvent());
                  context
                      .read<StatisticsBloc>()
                      .add(const StatisticsInitializationEvent());
                  Navigator.of(context).pop();
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideKeypad,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: formKey,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  BillButtonSection(
                                      onTap: _onDate,
                                      header: 'Date',
                                      text: DateFormat('dd MMM, yy')
                                          .format(_selectedDate),
                                      iconData: Icons.calendar_month),
                                  const Spacer(),
                                  BillButtonSection(
                                    onTap: _onTime,
                                    header: 'Time',
                                    text: _selectedTime
                                        .format(context)
                                        .toLowerCase(),
                                    iconData: Icons.access_time_outlined,
                                  )
                                ],
                              ),
                              const SizedBox(height: 50),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: TextFormField(
                                          controller: _billNameController,
                                          onTap: _hideKeypad,
                                          validator: _billNameValidation,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                              30,
                                            )
                                          ],
                                          decoration: const InputDecoration(
                                              hintText: "bill name"))),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: ProductTypeDropDown<BillType>(
                                      onChange: _onBillTypeChanged,
                                      value: _billType,
                                      onTapped: _hideKeypad,
                                      title: "Bill Type",
                                      items: billTypes,
                                      menuItemBuilder: (type) =>
                                          Text(type.name),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 35),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: TextFormField(
                                        controller: _amountController,
                                        onTap: _onAmountFieldTapped,
                                        readOnly: true,
                                        style: const TextStyle(fontSize: 18),
                                        validator: _amountFieldValidation,
                                        decoration: const InputDecoration(
                                            hintText: "amount paid"),
                                      )),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: ProductTypeDropDown<PaymentType>(
                                      value: _paymentType,
                                      onTapped: _hideKeypad,
                                      onChange: (type) =>
                                          setState(() => _paymentType = type!),
                                      title: "Payment Type",
                                      menuItemBuilder: _productItemBuilder,
                                      items: PaymentType.values,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 35),
                              Row(
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
                                    child: ProductTypeDropDown<Priority>(
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
                              const SizedBox(height: 20),
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
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        BillButtonSection(
                                          alignment: CrossAxisAlignment.center,
                                          onTap: _onEndDate,
                                          header: 'End Date:',
                                          iconData: Icons.calendar_month,
                                          text: _getEndDateText(),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: BlocBuilder<BillBloc, IBillingState>(
                            builder: (context, state) {
                              bool isProcessing = false;

                              if (state is BillSavingState) {
                                isProcessing = true;
                              }

                              return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    isProcessing
                                        ? const CircularProgressIndicator()
                                        : Visibility(
                                            visible: !_showKeypad,
                                            child: ElevatedButton(
                                                onPressed: onSubmit,
                                                style: _getButtonStyle(context),
                                                child: Text(toUpdate == null
                                                    ? "ADD"
                                                    : "Update")),
                                          ),
                                    const SizedBox(
                                      height: 15,
                                    )
                                  ]);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
                animation: _animController,
                builder: (_, widget) {
                  var yFactor = 1 - _animController.value;
                  return Transform.translate(
                    offset: Offset(0, yFactor * 30),
                    child: Visibility(
                      visible: _showKeypad,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            color: Theme.of(context).colorScheme.background,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomKeys(
                                  height: keysHeight,
                                  width: calcWidth,
                                  onKeyTapped: _onAmountChanged,
                                ),
                              ],
                            )),
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  void _showBillToUpdateData(Bill bill) {
    toUpdate = bill;
    _billNameController.text = bill.title;
    _descriptionController.text = bill.description ?? "";
    var amount = AppUtils.amountPresented(bill.amount);
    _amountController.text = '$amount';
    _calculator.add('$amount');

    _billType = toUpdate!.type;
    _paymentType = toUpdate!.paymentType;
    _priority = toUpdate!.priority;
    _selectedRecurrence = toUpdate!.pattern;
    _selectedDate = DateTime.parse(toUpdate!.paymentDateTime);
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);

    if (toUpdate?.endDate != null) {
      _endDate = DateTime.parse(toUpdate!.endDate!);
    }
  }

  String _getEndDateText() {
    return DateFormat('dd MMM, yy').format(
      _endDate ?? _selectedDate.add(const Duration(days: 365)),
    );
  }

  Widget _productItemBuilder(PaymentType type) {
    return Text(
      type.name,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }

  String? _amountFieldValidation(text) {
    if (text != null && text.isEmpty) {
      return 'Field can not be empty';
    }
    if (double.parse(text!) < 1) {
      return '0 is not allowed';
    }

    if (text.trim().length > 10) {
      return 'can\'t contain more than 10 characters';
    }

    return null;
  }

  void _onAmountFieldTapped() async {
    await Future.delayed(const Duration(milliseconds: 180));
    _animController.forward();
    setState(() => _showKeypad = true);
  }

  void _onBillTypeChanged(type) {
    setState(() => _billType = type);
  }

  String? _billNameValidation(text) {
    if (text != null && text.isEmpty) {
      return 'Field can not be empty';
    }
    return null;
  }

  void onSubmit() {
    bool isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_billType == null) {
      _showErrorDialog(context);
      return;
    }

    toUpdate == null ? _save() : _update();
  }

  void onRadio(Pattern? value) {
    _hideKeypad();
    setState(() {
      _selectedRecurrence = value!;

      if (_selectedRecurrence == Pattern.once) {
        _endDate = null;
      } else if (toUpdate != null && !(toUpdate!.isRecurring)) {
        _endDate = DateUtils.dateOnly(_selectedDate)
            .add(const Duration(days: 30, hours: 23, minutes: 59));
      } else if (toUpdate?.endDate != null) {
        _endDate = DateTime.parse(toUpdate!.endDate as String);
      }
    });
  }

  void _onTime() async {
    _hideKeypad();
    var time =
        await showTimePicker(context: context, initialTime: _selectedTime);
    setState(() => _selectedTime = time ?? _selectedTime);
  }

  void _onDate() async {
    _hideKeypad();
    var lastDate = DateTime.now().add(const Duration(days: 365 * 7));
    var isRecurring = toUpdate?.isRecurring;

    if (isRecurring != null && isRecurring) {
      lastDate = DateTime.parse(toUpdate!.paymentDateTime);
    }

    var date = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(199),
        lastDate: lastDate);

    setState(() {
      _selectedDate = date ?? _selectedDate;

      if (_selectedRecurrence == Pattern.once) return;

      if (_endDate!.isBefore(_selectedDate) &&
          toUpdate?.isRecurring != null &&
          !(toUpdate!.isRecurring)) {
        var start =
            DateUtils.dateOnly(DateTime.parse(toUpdate!.paymentDateTime));
        var end = DateUtils.dateOnly(_endDate!);
        var days = end.difference(start).inDays;
        _endDate = DateUtils.dateOnly(_selectedDate)
            .add(Duration(days: days, hours: 23, minutes: 59));
      }
    });
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
    var title = _billNameController.value.text;
    var date = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedDate.minute);

    var bill = Bill(
        title: title,
        description: description,
        paymentType: _paymentType,
        type: _billType!,
        paymentDateTime: date.toIso8601String(),
        amount: amount,
        priority: _priority,
        endDate: _endDate?.toIso8601String(),
        pattern: _selectedRecurrence);

    context.read<BillBloc>().add(BillSaveEvent(bill));
  }

  void _update() async {
    var amount = AppUtils.getActualAmount(_amountController.value.text);
    var description = _descriptionController.value.text;
    var bill = _billNameController.value.text;
    var date = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedDate.minute);

    Bill update = toUpdate!.copyWith(
      id: toUpdate!.id,
      title: bill,
      description: description,
      paymentDateTime: date.toIso8601String(),
      exceptionId: toUpdate!.exceptionId,
      amount: amount,
      parentId: toUpdate!.parentId,
      type: _billType,
      priority: _priority,
      pattern: _selectedRecurrence,
      paymentType: _paymentType,
      endDate: _endDate?.toIso8601String(),
    );

    var changedFields = Bill.differentFields(update, toUpdate!);

    if (changedFields.isEmpty) {
      await showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text('No change has been made'),
              ));
      return;
    }

    if (isRecurringAndPatternIsChanged()) {
      var ans = await updateQuestionAns(
          '''This change will modify all future events\nAre you sure?''');
      if (ans == null || !ans) return;
      var event = RecurringBillUpdateEvent(
          toUpdate!.paymentDateTime, update, UpdateMethod.multiple);

      sendEvent(event);
      return;
    }

    if (toUpdate!.isRecurring && !toUpdate!.isLast) {
      var ans = await updateQuestionAns('Should future events be updated?');
      if (ans == null) return;

      if (ans == true) {
        var event = RecurringBillUpdateEvent(
            toUpdate!.paymentDateTime, update, UpdateMethod.multiple);
        sendEvent(event);
        return;
      }

      var event = RecurringBillUpdateEvent(toUpdate!.paymentDateTime, update);
      sendEvent(event);
      return;
    }

    if (toUpdate!.isRecurring) {
      var event = RecurringBillUpdateEvent(toUpdate!.paymentDateTime, update);
      sendEvent(event);
      return;
    }

    var event = NonRecurringBillUpdateEvent(update);
    sendEvent(event);
  }

  void sendEvent(IBillEvent event) {
    context.read<BillBloc>().add(event);
  }

  bool isRecurringAndPatternIsChanged() {
    return toUpdate!.isRecurring && _selectedRecurrence != toUpdate!.pattern;
  }

  Future<dynamic> updateQuestionAns(String message) async {
    return await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(_, true),
              child: Text(
                'Yes',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: Text(
                'No',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            )
          ],
        );
      },
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(55),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
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
    _billNameController.text = '';
    _descriptionController.text = '';
    _billType = null;
    _calculator.clear();
    _endDate = null;
    _selectedRecurrence = Pattern.once;
    _paymentType = PaymentType.cash;
    _priority = Priority.need;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _hideKeypad() {
    if (!_showKeypad) return;
    _animController.reverse();
    _calculator.calculate();
    _amountController.text = _calculator.getString();
    setState(() => _showKeypad = false);
  }

  void _onEndDate() async {
    var date = await showDatePicker(
        context: context,
        initialDate: _endDate ?? _selectedDate,
        firstDate: _selectedDate,
        lastDate: _selectedDate.add(const Duration(days: 365 * 7)));
    setState(
      () => _endDate =
          date?.add(const Duration(hours: 23, minutes: 59)) ?? _endDate,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _billNameController.dispose();
    _animController.dispose();
    super.dispose();
  }
}

class BillButtonSection extends StatelessWidget {
  final Function() onTap;
  final String header;
  final String text;
  final IconData iconData;
  final CrossAxisAlignment alignment;

  const BillButtonSection(
      {super.key,
      required this.onTap,
      required this.header,
      required this.text,
      required this.iconData,
      this.alignment = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment,
        children: [
          Text(header),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 20),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(7)),
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    iconData,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ]);
  }
}
