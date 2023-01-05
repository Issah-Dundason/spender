import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/billing_state.dart';

import '../bloc/bill_bloc.dart';
import '../bloc/billing_event.dart';
import '../model/bill_type.dart';
import '../model/expenditure.dart';
import '../repository/expenditure_repo.dart';

class BillView extends StatelessWidget {
  final AppRepository appRepo;

  const BillView({Key? key, required this.appRepo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillBloc>(
      create: (context) =>
          BillBloc(appRepo: appRepo)..add(BillInitializationEvent()),
      child: const _BillSheet(),
    );
  }
}

class _BillSheet extends StatelessWidget {
  static final _formKey = GlobalKey<FormState>();

  const _BillSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: BlocBuilder<BillBloc, BillingState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                                initialValue: state.bill,
                                onChanged: (s) => context
                                    .read<BillBloc>()
                                    .add(BillTitleChangeEvent(s)),
                                decoration: const InputDecoration(
                                    hintText: "bill name"),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: _ProductTypeDropDown<BillType>(
                              onChange: (t) => context
                                  .read<BillBloc>()
                                  .add(BillTypeChangeEvent(t!)),
                              value: state.billType,
                              title: "Bill Type",
                              items: state.billTypes,
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
                                initialValue: state.amount,
                                onChanged: (s) => context
                                    .read<BillBloc>()
                                    .add(BillAmountChangeEvent(s)),
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
                              onChange: (t) => context
                                  .read<BillBloc>()
                                  .add(BillPaymentTypeEvent(t!)),
                              title: "Payment Type",
                              value: state.paymentType,
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
                              initialValue: state.description,
                              onChanged: (s) => context
                                  .read<BillBloc>()
                                  .add(BillDescriptionEvent(s)),
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 2,
                              maxLines: 9,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                  hintText: "description"),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: _ProductTypeDropDown<Priority>(
                              onChange: (t) => context
                                  .read<BillBloc>()
                                  .add(BillPriorityChangeEvent(t!)),
                              value: state.priority,
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
                      Center(
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              child: const Text("ADD")))
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
