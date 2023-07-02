import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/stats/statistics.dart';
import 'package:spender/pages/pie_chart_page.dart';

class WideScreenStats extends StatelessWidget {
  const WideScreenStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, IStatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoadingState) {
          return const CircularProgressIndicator();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Wrap(
                runSpacing: 10,
                children: [
                  StatButton(
                    text: 'Current Month',
                    selected: (state as StatisticsSuccessState).currentFilter == StatisticsFilterOption.currentMonth,
                    onTap: () {
                      context.read<StatisticsBloc>().add(StatisticsFilterChangeEvent(StatisticsFilterOption.currentMonth));
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  StatButton(
                    text: 'Current Year',
                    selected: state.currentFilter == StatisticsFilterOption.currentYear,
                    onTap: () {
                      context.read<StatisticsBloc>().add(StatisticsFilterChangeEvent(StatisticsFilterOption.currentYear));
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  StatButton(
                    text: 'Last Year',
                    selected: state.currentFilter == StatisticsFilterOption.lastYear,
                    onTap: () {
                      context.read<StatisticsBloc>().add(StatisticsFilterChangeEvent(StatisticsFilterOption.lastYear));
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  StatButton(
                    text: 'Overall',
                    selected: state.currentFilter == StatisticsFilterOption.overall,
                    onTap: () {
                      context.read<StatisticsBloc>().add(StatisticsFilterChangeEvent(StatisticsFilterOption.overall));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30,),
              Expanded(child: StatisticsChart(pieData: state.pieData))
            ],
          ),
        );
      },
    );
  }
}

class StatButton extends StatelessWidget {
  final String text;
  final bool selected;
  final Function()? onTap;

  const StatButton({
    Key? key,
    required this.text,
    this.onTap,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 17)),
          AnimatedIndicator(
            visible: selected,
          )
        ],
      ),
    );
  }
}

class AnimatedIndicator extends StatelessWidget {
  final bool visible;

  const AnimatedIndicator({Key? key, required this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 270),
      height: visible ? 3 : 0,
      width: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
