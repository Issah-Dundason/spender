import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:spender/model/model.dart';

import '../repository/expenditure_repo.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AppRepository appRepo;

  AppBloc({required this.appRepo}) : super(const AppState()) {
    on<AppStart>(_onStartHandler);
  }

  void _onStartHandler(AppEvent event, Emitter<AppState> emitter) {}
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  set currentState(HomeState state) => emit(state);
}

class BillBloc extends Bloc<BillEvent, BillingState> {
  final AppRepository appRepo;

  BillBloc({required this.appRepo})
      : super(const BillingState(
            paymentType: PaymentType.cash, priority: Priority.want)) {
    on<BillInitializationEvent>(_onInitialize);
  }

  _onInitialize(e, Emitter<BillingState> emitter) async {
    var records = await appRepo.getBillTypes();
    print("records: ${records.length}");
    emitter(state.copyWith(billTypes: records));
  }
}
