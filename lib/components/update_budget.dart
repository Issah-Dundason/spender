import 'package:flutter/material.dart';

class BudgetUpdate extends StatelessWidget {
  const BudgetUpdate({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Row(
        children: [
          Expanded(
              flex: 5,
              child: SizedBox(
                height: 40,
                child: TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(hintText: "enter monthly budget"),
                ),
              )),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Icon(Icons.update),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
