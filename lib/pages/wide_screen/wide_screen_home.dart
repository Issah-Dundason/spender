import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_state.dart';
import '../../components/home_chart.dart';
import '../../components/home_transactions.dart';
import '../../components/wide_screen/home_card.dart';
import '../home_page.dart';

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