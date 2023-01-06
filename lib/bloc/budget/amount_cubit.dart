import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:spender/repository/expenditure_repo.dart';

class AmountCubit extends Cubit<AmountState> {
  final AppRepository appRepos;

  AmountCubit(this.appRepos) : super(const AmountState(null));

  void initialize() async {
    DateTime date = DateTime.now();
    var yearMonth = DateFormat("yyyy-MM").format(date);
    var budget = await appRepos.getBudget(yearMonth);
    if (budget == null) return;
    var d = Decimal.fromInt(budget.amount);
    var r = d / Decimal.fromInt(100);
    emit(AmountState('${r.toDouble()}'));
  }

}

class AmountState extends Equatable {
  final String? amount;

  const AmountState(this.amount);

  @override
  List<Object?> get props => [amount];
}