part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object> get props => [];
}

class SubscribeToScheduleUpdates extends ScheduleEvent {}

class ScheduleUpdated extends ScheduleEvent {
  final TodayScheduleEntity schedule;
  const ScheduleUpdated(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class ScheduleErrorOccurred extends ScheduleEvent {
  final String message;
  const ScheduleErrorOccurred(this.message);

  @override
  List<Object> get props => [message];
}