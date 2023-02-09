import 'package:flutter/material.dart';

import '../icons/icons.dart';


class CustomKeys extends StatelessWidget {
  const CustomKeys(
      {Key? key,
        this.onKeyTapped,
        required this.height,
        required this.width,
        this.spacesAlongWidth = 8,
        this.spacesAlongHeight = 8})
      : super(key: key);
  final double height;
  final double width;
  final double spacesAlongWidth;
  final double spacesAlongHeight;
  final Function(String)? onKeyTapped;

  @override
  Widget build(BuildContext context) {
    var w1 = (width - spacesAlongWidth * 5) / 4;
    var h1 = (height - spacesAlongHeight * 6) / 5;

    return SizedBox(
      height: height,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NumPad(
                        width: w1,
                        height: h1,
                        value: const Icon(
                          Back.icon,
                          size: 35,
                          color: Colors.white,
                        ),
                        onTap: () {
                          onKeyTapped?.call('<');
                        },
                      ),
                      NumPad(
                        width: w1,
                        height: h1,
                        value: const Icon(MathDivider.icon, color: Colors.white,),
                        onTap: () {
                          onKeyTapped?.call('/');
                        },
                      ),
                      NumPad(
                        width: w1,
                        height: h1,
                        value: const Icon(Multiply.icon, color: Colors.white,),
                        onTap: () {
                          onKeyTapped?.call('x');
                        },
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText('7'),
                          onTap: () {
                            onKeyTapped?.call('7');
                          },
                        ),
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText('8'),
                          onTap: () {
                            onKeyTapped?.call('8');
                          },
                        ),
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText('9'),
                          onTap: () {
                            onKeyTapped?.call('9');
                          },
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText('4'),
                          onTap: () {
                            onKeyTapped?.call('4');
                          },
                        ),
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText('5'),
                          onTap: () {
                            onKeyTapped?.call('5');
                          },
                        ),
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText('6'),
                          onTap: () {
                            onKeyTapped?.call('6');
                          },
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText("3"),
                          onTap: () {
                            onKeyTapped?.call('3');
                          },
                        ),
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText("2"),
                          onTap: () {
                            onKeyTapped?.call('2');
                          },
                        ),
                        NumPad(
                          width: w1,
                          height: h1,
                          value: buildNumPadText("1"),
                          onTap: () {
                            onKeyTapped?.call('1');
                          },
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NumPad(
                          width: w1 * 2.1,
                          height: h1,
                          value: buildNumPadText("0"),
                          onTap: () {
                            onKeyTapped?.call('0');
                          },
                        ),
                        NumPad(
                          width: w1,
                          height: h1,
                          value: const Icon(Dot.icon, color: Colors.white,),
                          onTap: () {
                            onKeyTapped?.call('.');
                          },
                        ),
                      ]),
                ],
              )),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NumPad(
                  width: w1,
                  height: h1,
                  value: const Icon(
                    Minus.icon,
                    size: 6,
                    color: Colors.white,
                  ),
                  onTap: () {
                    onKeyTapped?.call('-');
                  },
                ),
                NumPad(width: w1, height: h1,value: buildNumPadText("C"), onTap: () {
                  onKeyTapped?.call("c");
                },),
                NumPad(
                  width: w1,
                  height: h1,
                  value: const Icon(Plus.icon, color: Colors.white,),
                  onTap: () {
                    onKeyTapped?.call('+');
                  },
                ),
                NumPad(
                  width: w1,
                  height: h1 * 2.13,
                  value: const Icon(
                    Equal.icon,
                    size: 15,
                    color: Colors.white,
                  ),
                  onTap: () {
                    onKeyTapped?.call('=');
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildNumPadText(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 29, color: Colors.white),
      ),
    );
  }
}

class NumPad extends StatelessWidget {
  const NumPad({
    Key? key,
    required this.value,
    this.onTap,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(0),
    required this.width,
    required this.height,
    this.color = const Color(0xFFF45737),
  }) : super(key: key);

  final Widget value;

  final EdgeInsets margin;

  final EdgeInsets padding;

  final double width;

  final double height;

  final Color color;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration:
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
      child: InkWell(
        onTap: onTap,
        child: value,
      ),
    );
  }
}
