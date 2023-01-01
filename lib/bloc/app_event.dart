import 'package:equatable/equatable.dart';

abstract class AppEvent{
  const AppEvent();
}

class AppStart extends AppEvent {
  const AppStart();
}
