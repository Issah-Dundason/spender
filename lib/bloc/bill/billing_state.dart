import 'package:equatable/equatable.dart';

enum ProcessingState { none, done, pending }

class BillingState extends Equatable {
  final ProcessingState processingState;

  const BillingState({this.processingState = ProcessingState.none});

  @override
  List<Object?> get props => [processingState];
}
