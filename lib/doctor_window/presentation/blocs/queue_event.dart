import 'package:equatable/equatable.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object> get props => [];
}

class LoadQueueEvent extends QueueEvent {}

class StartAppointmentEvent extends QueueEvent {
  final String ticket;

  const StartAppointmentEvent(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class EndAppointmentEvent extends QueueEvent {}