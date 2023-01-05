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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //header
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Number #${expenditure.id}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSecondary),
                    )
                  ],
                ),
              ),
              //body
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Bill: ${expenditure.bill}'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 20),
                child: Text('Amount: ${expenditure.cash}'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 20),
                child: Text(
                    'Payment type: ${expenditure.paymentType.name.toUpperCase()}'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 20),
                child: Text(
                    'Priority of service: ${expenditure.priority.name.toUpperCase()}'),
              ),
              if (expenditure.description != null)
                const Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 8),
                  child: Text('Description'),
                ),
              if (expenditure.description != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 6, right: 8.0),
                  child: Text(expenditure.description!),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border(
                                top: buildBorderSide(context),
                                left: buildBorderSide(context),
                                right: buildBorderSide(context))),
                        child: Text(expenditure.formattedDate)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  BorderSide buildBorderSide(BuildContext context) {
    return BorderSide(
        width: 0.9, color: Theme.of(context).colorScheme.secondary);
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
