
abstract class HomeEvent{
  const HomeEvent();
}

class HomeInitializationEvent extends HomeEvent {
  const HomeInitializationEvent();
}

class HomeAnalysisDateChangeEvent extends HomeEvent {
  final int year;

  HomeAnalysisDateChangeEvent(this.year);
}