import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/pages/wide_screen/wide_screen_statistic.dart';

import '../../bloc/app/app_cubit.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../components/appbar.dart';
import '../../icons/icons.dart';
import '../bill_view.dart';
import '../profile_page.dart';
import '../wide_screen/wide_screen_expenses.dart';
import '../wide_screen/wide_screen_home.dart';

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

        var width = MediaQuery.of(context).size.width;
        var showText = true;
        var flex = 3;

        if (width < 921) {
          showText = false;
          flex = 8;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 2,
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
                  fit: FlexFit.tight,
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
                          textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  textStyle: const TextStyle(fontSize: 16)))),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: showText,
                                child: TextButton(
                                    onPressed: onHome,
                                    style:
                                        getStyle(AppTab.home, state, context),
                                    child: const Text('Home')),
                              ),
                              Visibility(
                                  visible: !showText,
                                  child: IconButton(
                                      onPressed: onHome,
                                      icon: Icon(HomeIcon.icon,
                                          color: getAppColor(
                                              state == AppTab.home))))
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: showText,
                                child: TextButton(
                                    onPressed: () =>
                                        changeView(context, AppTab.expenses),
                                    style: getStyle(
                                        AppTab.expenses, state, context),
                                    child: const Text('Expenses')),
                              ),
                              Visibility(
                                visible: !showText,
                                child: IconButton(
                                  onPressed: () =>
                                      changeView(context, AppTab.expenses),
                                  icon: Icon(CardIcon.icon,
                                      color: getAppColor(
                                          state == AppTab.expenses)),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: showText,
                                child: TextButton(
                                    onPressed: () =>
                                        changeView(context, AppTab.add),
                                    style: getStyle(AppTab.add, state, context),
                                    child: const Text('Add Bill')),
                              ),
                              Visibility(
                                  visible: !showText,
                                  child: IconButton(
                                      onPressed: () =>
                                          changeView(context, AppTab.add),
                                      icon: Icon(
                                        Icons.add,
                                        color: getAppColor(state == AppTab.add),
                                      )))
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: showText,
                                child: TextButton(
                                    onPressed: () =>
                                        changeView(context, AppTab.statistics),
                                    style: getStyle(
                                        AppTab.statistics, state, context),
                                    child: const Text('Statistics')),
                              ),
                              Visibility(
                                visible: !showText,
                                child: IconButton(
                                  onPressed: () =>
                                      changeView(context, AppTab.statistics),
                                  icon: Icon(Icons.area_chart,
                                      color: getAppColor(
                                          state == AppTab.statistics)),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: showText,
                                child: TextButton(
                                    onPressed: () =>
                                        changeView(context, AppTab.settings),
                                    style: getStyle(
                                        AppTab.settings, state, context),
                                    child: const Text('Settings')),
                              ),
                              Visibility(
                                visible: !showText,
                                child: IconButton(
                                  onPressed: () =>
                                      changeView(context, AppTab.settings),
                                  icon: Icon(
                                    Icons.settings,
                                    color:
                                        getAppColor(state == AppTab.settings),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
              Flexible(
                fit: FlexFit.tight,
                flex: flex,
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
      ),
      AppTab.statistics: const WideScreenStats()
    };

    if (pages.containsKey(tab)) return pages[tab]!;

    return const BillView(showAppBar: false);
  }

  void onHome() {
    context.read<HomeBloc>().add(const HomeInitializationEvent());
    changeView(context, AppTab.home);
  }

  Color getAppColor(selected) {
    return selected ? Colors.white : Colors.black;
  }

  ButtonStyle? getStyle(AppTab actual, AppTab selected, BuildContext context) {
    if (actual != selected) return null;
    return TextButton.styleFrom(
      padding: EdgeInsets.zero,
      foregroundColor: Colors.white,
    );
  }

  void changeView(BuildContext context, AppTab tab) {
    context.read<AppCubit>().currentState = tab;
  }
}
