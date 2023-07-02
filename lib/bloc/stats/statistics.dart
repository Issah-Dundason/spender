import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:spender/service/database.dart';

import '../../repository/expenditure_repo.dart';

enum StatisticsFilterOption { currentMonth, currentYear, lastYear, overall }

Future<List<PieData>> getPieData(AppRepository repo, StatisticsFilterOption option) async {
  late List<PieData> pieData;

  if (option == StatisticsFilterOption.currentMonth) {
    String dbFormat = '\'%Y-%m\'';
    String date = DateFormat('yyyy-MM').format(DateTime.now());
    pieData = await repo.getPieData(dbFormat, date);
  }

  if (option == StatisticsFilterOption.currentYear) {
    String dbFormat = '\'%Y\'';
    String date = '${DateTime.now().year}';
    pieData = await repo.getPieData(dbFormat, date);
  }

  if (option == StatisticsFilterOption.lastYear) {
    String dbFormat = '\'%Y\'';
    String date = '${DateTime.now().year - 1}';
    pieData = await repo.getPieData(dbFormat, date);
  }

  if (option == StatisticsFilterOption.overall) {
    pieData = await repo.getOverallPieData();
  }

  return pieData;
}


abstract class IStatisticsState extends Equatable {
  const IStatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsLoadingState extends IStatisticsState {
  const StatisticsLoadingState();
}


class StatisticsSuccessState extends IStatisticsState{
  final StatisticsFilterOption currentFilter;
  final List<PieData> pieData;

  const StatisticsSuccessState([this.currentFilter = StatisticsFilterOption.currentMonth, this.pieData = const  []]);

  @override
  List<Object?> get props => [currentFilter, pieData];
}

abstract class StatisticsEvent {
  const StatisticsEvent();
}

class StatisticsFilterChangeEvent extends StatisticsEvent {
  final StatisticsFilterOption option;

  const StatisticsFilterChangeEvent(this.option);
}

class StatisticsInitializationEvent extends StatisticsEvent {
  const StatisticsInitializationEvent();
}


class StatisticsBloc extends Bloc<StatisticsEvent, IStatisticsState> {
  final AppRepository repo;

  StatisticsBloc(this.repo): super(const StatisticsLoadingState()) {
    on<StatisticsFilterChangeEvent>(_onFilterChanged);
    on<StatisticsInitializationEvent>(_onStart);
  }

  _onFilterChanged(StatisticsFilterChangeEvent e, Emitter<IStatisticsState> emit) async {
    emit(const StatisticsLoadingState());
    var data = await getPieData(repo, e.option);
    emit(StatisticsSuccessState(e.option, data));
  }

  _onStart(StatisticsInitializationEvent e, Emitter<IStatisticsState> emit) async {
    emit(const StatisticsLoadingState());

    var option = StatisticsFilterOption.currentMonth;
    var data = await getPieData(repo, option);

    emit(StatisticsSuccessState(option, data));
  }

}

