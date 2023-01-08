import 'package:flutter/material.dart';

class ExpenseAnalysisSection extends StatelessWidget {
  const ExpenseAnalysisSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 18),
        ),
        // const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(0, 0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {},
                child: const Text('Current Month')),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(0, 0),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {},
                child: const Text('Overall'))
          ],
        ),
      ],
    );
  }
}
