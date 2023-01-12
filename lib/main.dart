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
    home: Calculator(),
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
class Calculator extends StatefulWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              onTap: () {
                showModalBottomSheet(
                    barrierColor: Colors.transparent,
                    // anchorPoint: Offset(20, 0),
                    context: context,
                    builder: (_) => CustomKeys(
                          controller: controller,
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
  const CustomKeys({Key? key, required this.controller}) : super(key: key);
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    //var color = Theme.of(context).colorScheme.primary;

    var r = 5;
    var k = 5;
    var w1 = (size.width - r * 5) / 4;
    var l = (size.height * 0.4) / 5;
    var h1 = ((size.height * 0.4) - k * 6) / 5;

    return Container(
      height: size.height * 0.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NumPad(
                            width: w1,
                            height: h1,
                            value: const Icon(Back.icon, size: 35,)),
                        NumPad(
                            width: w1,
                            height: h1,
                            value: const Icon(MathDivider.icon)),
                        NumPad(
                            width: w1,
                            height: h1,
                            value: const Icon(Multiply.icon)),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText('7')),
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText('8')),
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText('9')),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText('4')),
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText('5')),
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText('6')),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText("3")),
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText("2")),
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText("1")),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          NumPad(
                              width: w1 * 2.1,
                              height: h1,
                              value: buildNumPadText("0")),
                          NumPad(
                              width: w1,
                              height: h1,
                              value: buildNumPadText(".")),
                        ])
                  ],
                ),
              )),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NumPad(width: w1, height: h1, value: buildNumPadText("-")),
                NumPad(width: w1, height: h1 * 2.13, value: buildNumPadText("+")),
                NumPad(
                    width: w1,
                    height: h1 * 2.13,
                    value: const Icon(
                      Equal.icon,
                      size: 15,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildNumPadText(String text) {
    return  Center(
      child:  Text(
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
      color: color,
      width: width,
      height: height,
      child: InkWell(
        onTap: onTap,
        child: value,
      ),
    );
  }
}
