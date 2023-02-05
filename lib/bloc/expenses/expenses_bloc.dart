import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/expenses/expenses_event.dart';
import 'package:spender/bloc/expenses/expenses_state.dart';
import 'package:spender/repository/expenditure_repo.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final AppRepository appRepo;

  ExpensesBloc({required this.appRepo})
      : super(ExpensesState(selectedDate: DateTime.now())) {
    on<ChangeDateEvent>(_onDateChange);
    on<OnStartEvent>(_onStart);
    on<LoadEvent>(_onLoad);
    on<RecurrentDeleteEvent>(_onRecurrentDelete);
    on<NonRecurringDelete>(_onNonRecurringDelete);
  }

  void _onDateChange(ChangeDateEvent e, Emitter<ExpensesState> emitter) async {
    var date = DateFormat("yyyy-MM-dd").format(e.selectedDate);
    var expenditures = await appRepo.getAllExpenditure(date);
    emitter(state.copyWith(
        selectedDate: e.selectedDate, transactions: expenditures));
  }

  void _onStart(OnStartEvent e, Emitter<ExpensesState> emitter) async {
    int? year = await appRepo.getYearOfFirstInsert();
    emitter(state.copyWith(yearOfFirstInsert: year, initialized: true));
  }

  void _onLoad(ExpensesEvent e, Emitter<ExpensesState> emitter) async {
    emitter(state.copyWith(transactions: []));
    var date = DateFormat("yyyy-MM-dd").format(state.selectedDate);
    var expenditures = await appRepo.getAllExpenditure(date);
    emitter(state.copyWith(transactions: expenditures));
  }

  void _onRecurrentDelete(
      RecurrentDeleteEvent e, Emitter<ExpensesState> emitter) {
    if(e.bill.isGenerated() && e.method == DeleteMethod.single) {
      _onDeleteSingleGenerated();
    }
    else if(e.bill.isGenerated() && e.method == DeleteMethod.multiple) {
      _onDeleteMultipleGenerated();
    } else if(!e.bill.isGenerated() && e.method == DeleteMethod.single) {
      _onDeleteSingle();
    } else {
      _onDeleteMultiple();
    }
  }

  void _onNonRecurringDelete(
      NonRecurringDelete e, Emitter<ExpensesState> emitter) {

  }

  void _onDeleteSingleGenerated() {

  }

  void _onDeleteMultipleGenerated() {}

  void _onDeleteSingle() {}

  void _onDeleteMultiple() {}
}
