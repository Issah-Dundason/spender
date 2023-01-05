import 'package:equatable/equatable.dart';

enum AppTab { home, expenses, bill }

class AppState extends Equatable {
  final AppTab previous;
  final AppTab current;

  const AppState({this.previous = AppTab.home, this.current = AppTab.home});

  copyWith({AppTab? previous, AppTab? current}) {
    return AppState(
        previous: previous ?? this.previous, current: current ?? this.current);
  }

  @override
  List<Object?> get props => [previous, current];
}