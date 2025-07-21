part of 'schedule_bloc.dart';

abstract class ScheduleEvent {}

class FetchScheduleData extends ScheduleEvent {
  final DateTime date;
  final int currentOrganizationId;
  //final List<Booking> bookings;

  FetchScheduleData({
    required this.date,
    required this.currentOrganizationId,
    //required this.bookings,
  });
}

class BuildSchedule extends ScheduleEvent {
  final DateTime currentTime;
  final DateTime startTime; // начало отсчета времени
  final DateTime endTime;
  final Duration timeInterval;
  final Duration minTimeInterval;
  final DateTime scheduleDay;
  final int? currentOrganizationId;
  //final List<Booking> bookings;

  BuildSchedule({
    //required this.bookings,
    required this.minTimeInterval,
    required this.currentTime,
    required this.startTime,
    required this.endTime,
    required this.timeInterval,
    required this.scheduleDay,
    this.currentOrganizationId,
  });
}

class FilterSchedule extends ScheduleEvent {}

class ToogleFilterItem extends ScheduleEvent {
  final String filterType;
  final String filterItemValue;

  ToogleFilterItem({
    required this.filterItemValue,
    required this.filterType,
  });
}

class ResetFilter extends ScheduleEvent {}

class ChangeScheduleOrder extends ScheduleEvent {
  final List<Booking> bookings;

  ChangeScheduleOrder({
    required this.bookings,
  });
}

class ChangeCurrentTime {
  final DateTime time;

  ChangeCurrentTime({
    required this.time,
  });
}

class RefreshSheduleData extends ScheduleEvent {}
