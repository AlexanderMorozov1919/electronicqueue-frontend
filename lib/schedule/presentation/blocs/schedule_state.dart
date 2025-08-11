part of 'schedule_bloc.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final TodayScheduleEntity schedule;
  final String? error;
  final DateTime timestamp;

  ScheduleLoaded(this.schedule, {this.error}) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [schedule, error, timestamp];

  ScheduleLoaded copyWith({
    TodayScheduleEntity? schedule,
    String? error,
    bool clearError = false,
  }) {
    return ScheduleLoaded(
      schedule ?? this.schedule,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}