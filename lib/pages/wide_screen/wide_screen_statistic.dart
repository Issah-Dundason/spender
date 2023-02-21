import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/stats/statistics.dart';
import 'package:spender/pages/pie_chart_page.dart';

class WideScreenStats extends StatelessWidget {
  const WideScreenStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatState>(
      builder: (context, state) {
        if (state is Loading) {
          return const CircularProgressIndicator();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  StatButton(
                    text: 'Current Month',
                    selected: state.currentFilter == FilterOptions.currentMonth,
                    onTap: () {
                      context.read<StatsBloc>().add(FilterChangeEvent(FilterOptions.currentMonth));
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  StatButton(
                    text: 'Current Year',
                    selected: state.currentFilter == FilterOptions.currentYear,
                    onTap: () {
                      context.read<StatsBloc>().add(FilterChangeEvent(FilterOptions.currentYear));
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  StatButton(
                    text: 'Last Year',
                    selected: state.currentFilter == FilterOptions.lastYear,
                    onTap: () {
                      context.read<StatsBloc>().add(FilterChangeEvent(FilterOptions.lastYear));
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  StatButton(
                    text: 'Overall',
                    selected: state.currentFilter == FilterOptions.overall,
                    onTap: () {
                      context.read<StatsBloc>().add(FilterChangeEvent(FilterOptions.overall));
                    },
                  ),
                ],
              ),
              Expanded(child: StatChart(pieData: state.pieData))
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
