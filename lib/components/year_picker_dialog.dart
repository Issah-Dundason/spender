import 'package:flutter/material.dart';

class YearPickerDialog extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime date) onChange;

  const YearPickerDialog(
      {Key? key,
      required this.selectedDate,
      required this.firstDate,
      required this.onChange,
      required this.lastDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
      content: SizedBox(
        width: 300,
        height: 300,
        child: YearPicker(
          firstDate: firstDate,
          lastDate: lastDate,
          onChanged: onChange,
          selectedDate: selectedDate,
        ),
      ),
    );
  }
}
