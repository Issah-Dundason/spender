import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/service/database.dart';

import '../../repository/expenditure_repo.dart';

enum FilterOptions { currentMonth, currentYear, lastYear, overall }

Future<List<PieData>> getPieData(AppRepository repo, FilterOptions option) async {
  late List<PieData> pieData;

  if (option == FilterOptions.currentMonth) {
    String dbFormat = '\'%Y-%m\'';
    String date = DateFormat('yyyy-MM').format(DateTime.now());
    pieData = await repo.getPieData(dbFormat, date);
  }

  if (option == FilterOptions.currentYear) {
    String dbFormat = '\'%Y\'';
    String date = '${DateTime.now().year}';
    pieData = await repo.getPieData(dbFormat, date);
  }

  if (option == FilterOptions.lastYear) {
    String dbFormat = '\'%Y\'';
    String date = '${DateTime.now().year - 1}';
    pieData = await repo.getPieData(dbFormat, date);
  }

  if (option == FilterOptions.overall) {
    pieData = await repo.getOverallPieData();
  }

  return pieData;
}

class StatState {
  final FilterOptions currentFilter;
  final List<PieData> pieData;

  StatState([this.currentFilter = FilterOptions.currentMonth, this.pieData = const  []]);
}

abstract class StatsEvent {}

class Loading extends StatState {}

class FilterChangeEvent extends StatsEvent {
  FilterOptions option;

  FilterChangeEvent(this.option);
}

class StartEvent extends StatsEvent {}

class StatsBloc extends Bloc<StatsEvent, StatState> {
  final AppRepository repo;

  StatsBloc(this.repo): super(StatState()) {
    on<FilterChangeEvent>(_onFilterChanged);
    on<StartEvent>(_onStart);
  }

  _onFilterChanged(FilterChangeEvent e, Emitter<StatState> emitter) async {
    emitter(Loading());
    var data = await getPieData(repo, e.option);
    emitter(StatState(e.option, data));
  }

  _onStart(StartEvent e, Emitter<StatState> emitter) async {
    var op = state.currentFilter;
    var data = await getPieData(repo, op);
    emitter(StatState(op, data));
  }

}

