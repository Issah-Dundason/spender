import 'package:bloc/bloc.dart';

enum AppTab { home, expenses}

class AppCubit extends Cubit<AppTab> {
  AppCubit() : super(AppTab.home);

  set currentState(AppTab tab) => emit(tab);
}