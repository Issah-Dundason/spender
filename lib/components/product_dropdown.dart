import 'package:flutter/material.dart';

class ProductTypeDropDown<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? value;
  final Widget Function(T) menuItemBuilder;
  final void Function(T?)? onChange;
  final Function()? onTapped;

  const ProductTypeDropDown(
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
            child: Text("--Select"),
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