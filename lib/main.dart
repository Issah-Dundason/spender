import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spender/bloc/expenses/expenses_bloc.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/bloc/profile/profile_event.dart';
import 'package:spender/model/expenditure.dart';
import 'package:spender/pages/app_view.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';
import 'package:spender/theme/theme.dart';
import 'package:spender/util/calculation.dart';

import 'bloc/app/app_cubit.dart';
import 'bloc/profile/profile_bloc.dart';
import 'icons/icons.dart';
import 'model/budget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClient dbClient = await DatabaseClient().init();

  AppRepository appRepo = AppRepository(dbClient);

  // DateTime date = DateTime.utc(2019, 02);
  //
  // var b = Budget(date.toIso8601String(), 323);
  //
  // appRepo.saveBudget(b);
  //
  // var types = await dbClient.getProductTypes();
  //
  // var expenditure = Expenditure.withDate("First Insert", "For testing",
  //     PaymentType.momo, types[0], DateTime.utc(2022, 05, 01).toIso8601String(), 100, Priority.want);
  //
  // await dbClient.saveExpenditure(expenditure.toJson());

  //check shared preference
  final prefs = await SharedPreferences.getInstance();
  String? avatar = prefs.getString("profile/avatar");
  //if avatar is not there
  //set it with 'tracker.svg'
  avatar ??= 'tracker.svg';

  runApp(const MaterialApp(
    home: CalculatorWidget(),
  ));

  // runApp(Spender(
  //   appRepo: appRepo,
  //   avatar: avatar,
  // ));
}

class Spender extends StatelessWidget {
  final String avatar;
  final AppRepository appRepo;

  const Spender({super.key, required this.appRepo, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => appRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => ProfileBloc()
                ..add(ProfileAvatarChangeEvent(assetName: avatar))),
        ],
        child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: MultiBlocProvider(
              providers: [
                BlocProvider(
                    create: (_) => HomeBloc(appRepo: appRepo)
                      ..add(const HomeInitializationEvent())),
                BlocProvider(create: (_) => AppCubit()),
                BlocProvider(
                    lazy: false,
                    create: (_) => ExpensesBloc(appRepo: appRepo)
                      ..add(const OnStartEvent())
                      ..add(const LoadEvent()))
              ],
              child: const AppView(),
            )),
      ),
    );
  }
}

//testing calculator
class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({Key? key}) : super(key: key);

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  final TextEditingController controller = TextEditingController();
  final calculator = Calculator();

  @override
  void initState() {
    controller.text = calculator.getString();
    super.initState();
  }

  void onKeyPressed(String input) {
    if(input == "=") {
      calculator.calculate();
    }
    else if(input == "<") {
      calculator.remove();
    }
    else {
      calculator.add(input);
    }
    controller.text = calculator.getString();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            TextField(
              controller: controller,
              showCursor: true,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 35),
              onTap: () {
                showModalBottomSheet(
                    barrierColor: Colors.transparent,
                    context: context,
                    builder: (_) => CustomKeys(
                          onKeyTapped: onKeyPressed,
                          width: size.width,
                          height: size.height * 0.4,
                        ));
              },
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}

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
                        ),
                        onTap: () {
                          onKeyTapped?.call('<');
                        },
                      ),
                      NumPad(
                        width: w1,
                        height: h1,
                        value: const Icon(MathDivider.icon),
                        onTap: () {
                          onKeyTapped?.call('/');
                        },
                      ),
                      NumPad(
                        width: w1,
                        height: h1,
                        value: const Icon(Multiply.icon),
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
                          value: const Icon(Dot.icon),
                          onTap: () {
                            onKeyTapped?.call('.');
                          },
                        ),
                      ])
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
                  ),
                  onTap: () {
                    onKeyTapped?.call('-');
                  },
                ),
                NumPad(
                  width: w1,
                  height: h1 * 2.13,
                  value: const Icon(Plus.icon),
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
        style: const TextStyle(fontSize: 29),
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
    this.color = Colors.blue,
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
