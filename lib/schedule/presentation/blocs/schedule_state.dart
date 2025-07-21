part of 'schedule_bloc.dart';

abstract class ScheduleState {
  const ScheduleState();
}

class ScheduleInit extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final DateTime scheduleDay; // день для которого отображается расписание
  final DateTime currentTime; // текущее время
  final DateTime startTime; // начало отсчета времени
  final DateTime endTime; // конец отсчета времени
  final Duration timeInterval; // интервал времени для расписания
  final Duration minTimeInterval;
  final List<Booking> bookings; // список бронирований (столбцов)
  final ScheduleFilter filter; // фильтры
  final List<TimePoint> timePoints;
  // список организаций

  const ScheduleLoaded({
    required this.scheduleDay,
    required this.currentTime,
    required this.startTime,
    required this.endTime,
    required this.timeInterval,
    required this.bookings,
    required this.filter,
    required this.timePoints,
    required this.minTimeInterval,
  });
}

class ScheduleError extends ScheduleState {}
