import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/budget/amount_cubit.dart';

import '../bloc/budget/budget_review_bloc.dart';
import '../bloc/budget/budget_review_event.dart';

class BudgetUpdate extends StatefulWidget {
  const BudgetUpdate({Key? key}) : super(key: key);
  @override
  State<BudgetUpdate> createState() => _BudgetUpdateState();
}

class _BudgetUpdateState extends State<BudgetUpdate> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AmountCubit, AmountState>(
      builder: (context, state) {
        if(state.amount != null) {
          amountController.text = state.amount!;
        }
        return Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: TextFormField(
                   controller: amountController,
                    validator: (s) {
                      if (s == null || s.isEmpty) return 'enter an amount';
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d+)?\.?\d{0,2}'))
                    ],
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                    const InputDecoration(hintText: "enter budget for month"),
                  )),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _handleSubmit(context),
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Theme
                            .of(context)
                            .colorScheme
                            .secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Set'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmit(BuildContext context) {
    bool valid = _formKey.currentState!.validate();
    if (!valid) return;
    context
        .read<BudgetReviewBloc>()
        .add(SaveBudgetEvent(amount: amountController.text));
  }
}
