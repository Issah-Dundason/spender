import 'package:bloc/bloc.dart';

enum AppTab { home, expenses, settings, add, statistics}

class AppCubit extends Cubit<AppTab> {
  AppCubit() : super(AppTab.home);

  set currentState(AppTab tab) => emit(tab);
}