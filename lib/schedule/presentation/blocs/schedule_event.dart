// D:\vs\go\electronicqueue-frontend\lib\schedule\presentation\blocs\schedule_event.dart

part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object> get props => [];
}

class SubscribeToScheduleUpdates extends ScheduleEvent {}

class _ScheduleUpdated extends ScheduleEvent {
  final TodayScheduleEntity schedule;
  const _ScheduleUpdated(this.schedule);

  @override
  List<Object> get props => [schedule];
}

// --- НАЧАЛО ИЗМЕНЕНИЙ ---
class _ScheduleErrorOccurred extends ScheduleEvent {
  final String message;
  const _ScheduleErrorOccurred(this.message);

  @override
  List<Object> get props => [message];
}
// --- КОНЕЦ ИЗМЕНЕНИЙ ---