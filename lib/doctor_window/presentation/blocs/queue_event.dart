import 'package:equatable/equatable.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object> get props => [];
}

class LoadQueueEvent extends QueueEvent {}

class StartAppointmentEvent extends QueueEvent {}

class EndAppointmentEvent extends QueueEvent {}

class StartBreakEvent extends QueueEvent {}

class EndBreakEvent extends QueueEvent {}
