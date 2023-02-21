import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home/home_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/components/appbar.dart';
import 'package:spender/components/home_chart.dart';
import 'package:spender/components/home_transactions.dart';
import 'package:spender/icons/icons.dart';
import 'package:spender/model/bill_type.dart';
import 'package:spender/pages/profile_page.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:intl/intl.dart' show NumberFormat, toBeginningOfSentenceCase;
import 'package:spender/util/app_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import '../bloc/app/app_cubit.dart';
import '../bloc/bill/bill_bloc.dart';
import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/expenses/expenses_event.dart';
import '../bloc/expenses/expenses_state.dart';
import '../bloc/home/home_state.dart';
import '../bloc/profile/profile_bloc.dart';
import '../components/expenses_calendar.dart';
import '../components/expenses_transactions.dart';
import 'bill_view.dart';
import 'expenses.dart';
import 'home_page.dart';
import 'dart:math' as math;

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(hours: 1), (timer) {
      context.read<ExpensesBloc>().add(const LoadEvent());
      context.read<HomeBloc>().add(const HomeInitializationEvent());
    });

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;

    if(query.width < 450 || query.height < 450) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp
      ]);
    }

    return LayoutBuilder(
      builder: (context, constraint) {
        if (constraint.maxWidth > 450) {
          return const WiderWidthView();
        }
        int index = context.read<AppCubit>().state.index;
        if (index == 2 || index == 3) {
          context.read<AppCubit>().currentState = AppTab.home;
        }
        context.read<ExpensesBloc>().add(const LoadEvent());
        return const NarrowWidthView();
      },
    );
  }
}

class WiderWidthView extends StatefulWidget {

  const WiderWidthView({Key? key}) : super(key: key);

  @override
  State<WiderWidthView> createState() => _WiderWidthViewState();
}

class _WiderWidthViewState extends State<WiderWidthView> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppTab>(
      builder: (context, state) {
        final profileState = context.select((ProfileBloc bloc) => bloc.state);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            leading: ProfileIcon(
              assetName: profileState.currentAvatar,
            ),
            title: const Text('Tracedi'),
            backgroundColor: Colors.white,
            centerTitle: true,
            foregroundColor: Colors.black,
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: const Alignment(0.8, 1),
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary
                            ])),
                    child: Theme(
                      data: ThemeData(
                        textButtonTheme:TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white
                          )
                        )
                      ),
                      child: ListView(
                        children: [
                          TextButton(
                              onPressed: () {
                                context.read<HomeBloc>().add(const HomeInitializationEvent());
                                changeView(context, AppTab.home);
                              },
                              style: getStyle(AppTab.home, state, context),
                              child: const Text(
                                'Home',
                                textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 19)
                              )),
                          TextButton(
                              onPressed: () =>
                                  changeView(context, AppTab.expenses),
                              style: getStyle(AppTab.expenses, state, context),
                              child: const Text('Expenses', style: TextStyle(fontSize: 16),)),
                          TextButton(
                              onPressed: () => changeView(context, AppTab.add),
                              style: getStyle(AppTab.add, state, context),
                              child: const Text('Add Bill', style: TextStyle(fontSize: 16))),
                          TextButton(
                              onPressed: () =>
                                  changeView(context, AppTab.settings),
                              style: getStyle(AppTab.settings, state, context),
                              child: const Text('Settings', style: TextStyle(fontSize: 16)))
                        ],
                      ),
                    ),
                  )),
              // Container(width: 10, color: Colors.blue,),
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                  )),
                  child: getDisplayWidget(state),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget getDisplayWidget(AppTab tab) {
    var pages = {
      AppTab.home: const WiderScreenHome(),
      AppTab.expenses: const WiderScreenExpenses(),
      AppTab.settings: const AppProfile(
        showAppbar: false,
      )
    };

    if (pages.containsKey(tab)) return pages[tab]!;

    var repo = context.read<AppRepository>();
    return FutureBuilder<List<BillType>>(
        future: repo.getBillTypes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return BlocProvider(
            create: (_) => BillBloc(appRepo: repo),
            child: BillView(
              showAppBar: false,
              billTypes: snapshot.requireData,
            ),
          );
        });
  }

  ButtonStyle? getStyle(AppTab actual, AppTab selected, BuildContext context) {
    if (actual != selected) return null;
    return TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        minimumSize: const Size.fromHeight(40),
        padding: EdgeInsets.zero,
        foregroundColor: Colors.white,
    );
  }

  void changeView(BuildContext context, AppTab tab) {
    context.read<AppCubit>().currentState = tab;
  }
}

class WiderScreenHome extends StatelessWidget {
  const WiderScreenHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          color: Theme.of(context).colorScheme.background,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (state.currentFinancials == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text(
                            'Set a budget for this month in settings', style: TextStyle(fontSize: 18),),
                      )
                    else
                      Column(
                        children: [
                          const SizedBox(height: 15,),
                          const Text('Month Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                          const SizedBox(height: 13),
                          Wrap(
                            children: [
                              WiderScreenHomeCard(
                                  title: 'Budget',
                                  amount:
                                      state.currentFinancials!.budget),
                              const SizedBox(width: 14),
                              WiderScreenHomeCard(
                                  title: 'Amount left',
                                  amount:
                                      state.currentFinancials!.balance),
                              const SizedBox(width: 14),
                              WiderScreenHomeCard(
                                  title: 'Amount spent',
                                  amount: state
                                      .currentFinancials!.amountSpent)
                            ],
                          )
                        ],
                      ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Analytics (Amount Spent)",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          HomeYearBtn(year: state.analysisYear)
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChartWidget(state: state),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
              const SliverToBoxAdapter(child:
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: HomeTransactions(horizontalCardsCount: 2,),
              ),),
            ],
          ),
        );
      },
    );
  }
}

class WiderScreenHomeCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color textColor;

  const WiderScreenHomeCard(
      {Key? key,
      required this.title,
      required this.amount,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(minWidth: 200),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: const Alignment(0.8, 1),
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ])),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.2),
        child: Column(
          children: [
            Text(
              '$title: ',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('₵ ${NumberFormat().format(AppUtils.amountPresented(amount))}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 16))
          ],
        ),
      ),
    );
  }
}

class WiderScreenExpenses extends StatelessWidget {
  const WiderScreenExpenses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Row(children: [
        const Flexible(
          flex: 3,
          child: ExpensesTransactions(),),
        Flexible(flex: 2,
            child: Column(
              children: [
                BlocBuilder<ExpensesBloc, ExpensesState>(
                  builder: (context, state) {
                    if (state.yearOfFirstInsert == null && !state.initialized) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return TransactionCalendar(
                        selectedDay: state.selectedDate,
                        calendarFormat: CalendarFormat.month,
                        firstYear:
                        state.yearOfFirstInsert ?? DateTime.now().year,
                        onDateSelected: (date, focus) {
                          context
                              .read<ExpensesBloc>()
                              .add(ChangeDateEvent(date));
                        });
                  },
                ),
                const Clock()
              ],
            ))
      ],),
    );
  }
}

class Clock extends StatelessWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: AspectRatio(aspectRatio: 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration:  BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 12, color: Colors.grey.shade300),
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration:  BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 12, color: Colors.grey.shade300),
              ),
            ),
           // const CircleAvatar(radius: 12,),
            const ClockFace(),
            const ClockHands(),
            const CircleAvatar(radius: 10,)
          ],
        ),
      ),
    );
  }
}

class ClockFace extends StatelessWidget {
  const ClockFace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: ClockNumberPainter(),
          ),
        )
      ],
    );
  }
}

class ClockNumberPainter extends CustomPainter {

  final hourTickLength = 15.0;
  final minuteTickLength = 9.0;

  final hourTickWidth = 3.0;
  final minuteTickWidth = 1.5;

  late Paint tickPaint;

  ClockNumberPainter() {
    tickPaint = Paint()..color = Colors.blueGrey..strokeWidth = 10;
  }

  @override
  void paint(Canvas canvas, Size size) {
   const angle = 2 * math.pi / 60;
   final radius = size.width / 2;

   canvas.save();


   canvas.translate(radius, radius);
   canvas.rotate(1.5 * math.pi);

    for(var i = 0; i < 60; i++) {
      var markLength = i % 5 == 0 ? hourTickLength: minuteTickLength;
      tickPaint.strokeWidth = i % 5 == 0 ? hourTickWidth : minuteTickWidth;

      canvas.drawLine(Offset(-radius + 20, 0), Offset(-radius + 20 + markLength, 0), tickPaint);
      canvas.rotate(angle);
    }

   canvas.restore();

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return false;
  }
}

class ClockHands extends StatefulWidget {
  const ClockHands({Key? key}) : super(key: key);

  @override
  State<ClockHands> createState() => _ClockHandsState();
}

class _ClockHandsState extends State<ClockHands> {
  late Timer _timer;
  late DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _setTime);
  }

  void _setTime(Timer timer) {
    setState(() {
      dateTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(painter: ClockHandPainter(hours: dateTime.hour, minutes: dateTime.minute),),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}


class ClockHandPainter extends CustomPainter {
  late Paint handPainter;
  late Paint minutePainter;
  int hours;
  int minutes;


  ClockHandPainter({required this.hours, required this.minutes}) {
    handPainter = Paint()..color = Colors.redAccent;
    minutePainter = Paint()..color = Colors.lightBlue;
    handPainter.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(radius, radius);
    canvas.rotate(1.5 * math.pi);

    canvas.save();

    int hr = hours % 12;

    var hourAngle = hr * (math.pi / 6);
    var totalHrAngle = hourAngle + (minutes / 60)  * (math.pi / 6);

    canvas.rotate(totalHrAngle);

    Path path =  Path();

    var bubbleBtm = radius * 0.042;

    path.moveTo(bubbleBtm, - bubbleBtm);

    path.quadraticBezierTo(0, 0, bubbleBtm, bubbleBtm);

    path.lineTo(radius * 0.7, 0);

    path.close();

    canvas.drawPath(path, handPainter);

    canvas.restore();

    canvas.save();

    var minuteAngle = (2 * math.pi / 60) * minutes;
    canvas.rotate(minuteAngle);

    path =  Path();

    bubbleBtm = radius * 0.042;

    path.moveTo(bubbleBtm, - bubbleBtm);

    path.quadraticBezierTo(0, 0, bubbleBtm, bubbleBtm);

    path.lineTo(radius * 0.4, 0);

    path.close();

    canvas.drawPath(path, minutePainter);

    canvas.restore();


    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

class NarrowWidthView extends StatefulWidget {
  const NarrowWidthView({
    Key? key,
  }) : super(key: key);

  @override
  State<NarrowWidthView> createState() => _NarrowWidthViewState();
}

class _NarrowWidthViewState extends State<NarrowWidthView> {
  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((AppCubit bloc) => bloc.state);
    final profileState = context.select((ProfileBloc bloc) => bloc.state);
    return Scaffold(
      appBar: TopBar.getAppBar(
          context,
          toBeginningOfSentenceCase(selectedTab.name) as String,
          profileState.currentAvatar, () async {
        await Navigator.of(context).push(TopBar.createRoute());
        if (!mounted) return;
        context.read<HomeBloc>().add(const HomeInitializationEvent());
      }),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: IndexedStack(
        index: selectedTab.index,
        children: const [HomePage(), ExpensesPage()],
      ),
      bottomNavigationBar: const _MainBottomAppBar(),
    );
  }
}

class _MainBottomAppBar extends StatefulWidget {
  const _MainBottomAppBar({Key? key}) : super(key: key);

  @override
  State<_MainBottomAppBar> createState() => _MainBottomAppBarState();
}

class _MainBottomAppBarState extends State<_MainBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppTab>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  color: state == AppTab.home
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  alignment: Alignment.center,
                  splashRadius: 30,
                  onPressed: () =>
                      context.read<AppCubit>().currentState = AppTab.home,
                  icon: const Icon(HomeIcon.icon)),
              CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: IconButton(
                      splashRadius: 30,
                      onPressed: _addBill,
                      icon: const Icon(AddIcon.icon))),
              IconButton(
                  color: state == AppTab.expenses
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  splashRadius: 30,
                  onPressed: () =>
                      context.read<AppCubit>().currentState = AppTab.expenses,
                  icon: const Icon(
                    CardIcon.icon,
                  )),
            ],
          ),
        );
      },
    );
  }

  void _addBill() async {
    await _showAddBillView();
    if (!mounted) return;
    context.read<ExpensesBloc>().add(const LoadEvent());
    context.read<HomeBloc>().add(const HomeInitializationEvent());
  }

  Future<dynamic> _showAddBillView() async {
    var appRepo = context.read<AppRepository>();
    var billTypes = await appRepo.getBillTypes();

    if (!mounted) return;

    return Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider(
            create: (_) {
              return BillBloc(appRepo: appRepo);
            },
            child: BillView(
              billTypes: billTypes,
            ))));
  }
}
