import 'package:flutter/material.dart';

import '../model/expenditure.dart';

class Receipt extends StatelessWidget {
  final Expenditure expenditure;

  const Receipt({Key? key, required this.expenditure}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Center(
      child: ClipPath(
        clipBehavior: Clip.antiAlias,
        clipper: ReceiptClipper(),
        child: Container(
          width: size.width * 0.7,
          height: size.height * 0.5,
          color: Theme.of(context).colorScheme.background,
          //  color: Theme.of(context).colorScheme.primary,
          child: Column(
            children: [
              Container(
                height: 50,
                color: Theme.of(context).colorScheme.secondary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Transaction',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    Text('Number #${expenditure.id}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double squareLength = 5;
    squareLength = (size.width / 200) * squareLength;

    Path path = Path()..moveTo(0, 0);

    for (double i = 0; i <= size.width - squareLength; i += squareLength) {
      path.lineTo(i + (squareLength / 2), squareLength);
      path.lineTo(i + squareLength, 0);
    }

    path.lineTo(size.width, size.height);
    double i = 0;
    for (i = size.width; i > 0; i -= squareLength) {
      path.lineTo(i - (squareLength / 2), size.height - squareLength);
      path.lineTo(i - squareLength, size.height);
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
