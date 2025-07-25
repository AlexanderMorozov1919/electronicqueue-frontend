import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../domain/entities/booking.dart';
import '../../domain/usecases/get_schedule.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/schedule_repository_impl.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';


class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc() : super(ScheduleInit()) {
    on<FetchScheduleData>(_onFetchScheduleData);
    on<BuildSchedule>(_onBuildSchedule);
    on<FilterSchedule>(_onFilterSchedule);
    on<ChangeScheduleOrder>(_onChangeScheduleOrder);
    on<ToogleFilterItem>(_onToogleFilterItem);
    on<ResetFilter>(_onResetFilter);
    on<RefreshSheduleData>(_onRefreshSheduleData);
  }

  Future<void> _onRefreshSheduleData(
      RefreshSheduleData event, Emitter<ScheduleState> emit) async {
    try {
      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        DateFormat formatter = DateFormat('yyyy-MM-dd');

        final GetSchedule getSchedule = GetSchedule(ScheduleRepositoryImpl());
        final List<Booking> bookings = await getSchedule.execute(
            formatter.format(currentState.scheduleDay), 1);

        final List<DateTime> bookingsTimes =
            _getBookingsTimes(bookings: bookings);

        final List<TimePoint> timePoints = _generateTimeSlots(
            startTime: currentState.startTime,
            endTime: currentState.endTime,
            timeInterval: currentState.timeInterval,
            bookingTimePoints: bookingsTimes);

        final ScheduleFilter scheduleFilter =
            ScheduleFilter.fromBookings(bookings);

        emit(ScheduleLoaded(
          scheduleDay: currentState.scheduleDay,
          currentTime: currentState.currentTime,
          startTime: currentState.startTime,
          endTime: currentState.endTime,
          timeInterval: currentState.timeInterval,
          bookings: bookings,
          filter: scheduleFilter,
          timePoints: timePoints,
          minTimeInterval: currentState.minTimeInterval,
        ));
      }
    } catch (e) {
      emit(ScheduleError());
    }
  }

  Future<void> _onFetchScheduleData(
      FetchScheduleData event, Emitter<ScheduleState> emit) async {
    try {
      final currentState = state as ScheduleLoaded;
      DateFormat formatter = DateFormat('yyyy-MM-dd');

      final GetSchedule getSchedule = GetSchedule(ScheduleRepositoryImpl());
      final List<Booking> bookings = await getSchedule.execute(
          formatter.format(event.date), 1);

      final List<DateTime> bookingsTimes =
          _getBookingsTimes(bookings: bookings);

      final List<TimePoint> timePoints = _generateTimeSlots(
          startTime: currentState.startTime,
          endTime: currentState.endTime,
          timeInterval: currentState.timeInterval,
          bookingTimePoints: bookingsTimes);

      final ScheduleFilter scheduleFilter =
          ScheduleFilter.fromBookings(bookings);

      emit(ScheduleLoaded(
        scheduleDay: currentState.scheduleDay,
        currentTime: currentState.currentTime,
        startTime: currentState.startTime,
        endTime: currentState.endTime,
        timeInterval: currentState.timeInterval,
        bookings: bookings,
        filter: scheduleFilter,
        timePoints: timePoints,
        minTimeInterval: currentState.minTimeInterval,
      ));
    } catch (e) {
      emit(ScheduleError());
    }
  }

  Future<void> _onBuildSchedule(
      BuildSchedule event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final GetSchedule getSchedule = GetSchedule(ScheduleRepositoryImpl());
      final List<Booking> bookings = await getSchedule.execute(
          formatter.format(event.scheduleDay), 1);

      final List<DateTime> bookingsTimes =
          _getBookingsTimes(bookings: bookings);

      final List<TimePoint> timePoints = _generateTimeSlots(
          startTime: event.startTime,
          endTime: event.endTime,
          timeInterval: event.timeInterval,
          bookingTimePoints: bookingsTimes);

      final ScheduleFilter scheduleFilter =
          ScheduleFilter.fromBookings(bookings);

      emit(ScheduleLoaded(
        scheduleDay: event.scheduleDay,
        currentTime: event.currentTime,
        startTime: event.startTime,
        endTime: event.endTime,
        timeInterval: event.timeInterval,
        bookings: bookings,
        filter: scheduleFilter,
        timePoints: timePoints,
        minTimeInterval: event.minTimeInterval,
      ));
    } catch (e) {
      emit(ScheduleError());
      print(e);
    }
  }

  void _onToogleFilterItem(
      ToogleFilterItem event, Emitter<ScheduleState> emit) {
    final currentState = state as ScheduleLoaded;
    final ScheduleFilter currentFilter = currentState.filter;

    ScheduleFilter updatedFilter;

    List<FilterItem>? toggleItem(List<FilterItem>? items) {
      if (items == null) return null;
      return items.map((item) {
        if (item.title == event.filterItemValue) {
          return FilterItem(title: item.title, value: !item.value);
        }
        return item;
      }).toList();
    }

    switch (event.filterType) {
      case 'branch':
        updatedFilter = ScheduleFilter(
          branch: toggleItem(currentFilter.branch),
          department: currentFilter.department,
          equipmentType: currentFilter.equipmentType,
          filterEnabled: currentFilter.filterEnabled,
        );
        break;
      case 'department':
        updatedFilter = ScheduleFilter(
          branch: currentFilter.branch,
          department: toggleItem(currentFilter.department),
          equipmentType: currentFilter.equipmentType,
          filterEnabled: currentFilter.filterEnabled,
        );
        break;
      case 'equipmentType':
        updatedFilter = ScheduleFilter(
          branch: currentFilter.branch,
          department: currentFilter.department,
          equipmentType: toggleItem(currentFilter.equipmentType),
          filterEnabled: currentFilter.filterEnabled,
        );
        break;
      default:
        updatedFilter = currentFilter;
    }

    emit(ScheduleLoaded(
      scheduleDay: currentState.scheduleDay,
      currentTime: currentState.currentTime,
      startTime: currentState.startTime,
      endTime: currentState.endTime,
      timeInterval: currentState.timeInterval,
      bookings: currentState.bookings,
      filter: updatedFilter,
      timePoints: currentState.timePoints,
      minTimeInterval: currentState.minTimeInterval,
    ));
  }

  Future<void> _onFilterSchedule(
      FilterSchedule event, Emitter<ScheduleState> emit) async {
    if (state is ScheduleLoaded) {
      try {
        final currentState = state as ScheduleLoaded;
        DateFormat formatter = DateFormat('yyyy-MM-dd');

        final GetSchedule getSchedule = GetSchedule(ScheduleRepositoryImpl());
        final List<Booking> bookings = await getSchedule.execute(
            formatter.format(currentState.scheduleDay), 1);

        final bool isFilterEmpty = currentState.filter.areAllValuesFalse();

        List<Booking> filteredBookings = bookings;

        if (!isFilterEmpty) {
          filteredBookings = bookings.where((booking) {
            final actor = booking.actor;

            bool matchesBranch = currentState.filter.branch != null &&
                currentState.filter.branch!.any((item) =>
                    item.title == actor.branchName && item.value == true);

            

            bool matchesEquipmentType = currentState.filter.equipmentType !=
                    null &&
                currentState.filter.equipmentType!.any((item) =>
                    item.title == actor.equipmentType && item.value == true);

            return matchesBranch || matchesEquipmentType;
          }).toList();
        }

        // Генерация временных точек
        final List<DateTime> bookingsTimes =
            _getBookingsTimes(bookings: filteredBookings);

        final List<TimePoint> timePoints = _generateTimeSlots(
            startTime: currentState.startTime,
            endTime: currentState.endTime,
            timeInterval: currentState.timeInterval,
            bookingTimePoints: bookingsTimes);

        // Обновление состояния
        emit(ScheduleLoaded(
          minTimeInterval: currentState.minTimeInterval,
          scheduleDay: currentState.scheduleDay,
          currentTime: currentState.currentTime,
          startTime: currentState.startTime,
          endTime: currentState.endTime,
          timeInterval: currentState.timeInterval,
          bookings: filteredBookings,
          filter: currentState.filter,
          timePoints: timePoints,
        ));
      } catch (e) {
        print(e);
      }
    }
  }

  void _onResetFilter(ResetFilter event, Emitter<ScheduleState> emit) {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;
      emit(ScheduleLoaded(
        minTimeInterval: currentState.minTimeInterval,
        scheduleDay: currentState.scheduleDay,
        currentTime: currentState.currentTime,
        startTime: currentState.startTime,
        endTime: currentState.endTime,
        timeInterval: currentState.timeInterval,
        bookings: currentState.bookings,
        filter: currentState.filter.resetAllValuesToFalse(),
        timePoints: currentState.timePoints,
      ));
    }
  }

  Future<void> _onChangeScheduleOrder(
      ChangeScheduleOrder event, Emitter<ScheduleState> emit) async {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;

      emit(ScheduleLoaded(
        scheduleDay: currentState.scheduleDay,
        currentTime: currentState.currentTime,
        startTime: currentState.startTime,
        endTime: currentState.endTime,
        timeInterval: currentState.timeInterval,
        bookings: event.bookings,
        filter: currentState.filter,
        minTimeInterval: currentState.minTimeInterval,
        timePoints: currentState.timePoints,
      ));
    }
  }

  List<DateTime> _getBookingsTimes({
    required List<Booking> bookings,
  }) {
    List<DateTime> timeSlots = [];
    for (Booking booking in bookings) {
      timeSlots.addAll(booking.getTimes());
    }
    Set<DateTime> uniqueTimeSlots = Set<DateTime>.from(timeSlots);
    List<DateTime> result = uniqueTimeSlots.toList()
      ..sort((a, b) => a.compareTo(b));

    return result;
  }

  List<TimePoint> _generateTimeSlots({
    required DateTime startTime,
    required DateTime endTime,
    required Duration timeInterval,
    required List<DateTime> bookingTimePoints,
  }) {
    //
    final Duration interval = (timeInterval.inMinutes % 2 == 0)
        ? Duration(minutes: timeInterval.inMinutes ~/ 2)
        : timeInterval;

    // Проверка входных данных
    if (startTime.isAfter(endTime)) {
      throw ArgumentError("Start time cannot be after end time.");
    }

    // Генерация временных слотов с isAxis = true
    List<TimePoint> timeSlots = [];
    DateTime currentTime = startTime;

    while (!currentTime.isAfter(endTime)) {
      timeSlots.add(TimePoint(
          isAxis: (((currentTime.difference(startTime).inMinutes ~/
                              interval.inMinutes) %
                          2 !=
                      0) &&
                  (timeInterval != interval))
              ? false
              : true,
          time: currentTime));
      currentTime = currentTime.add(interval);
    }

    // Добавление bookingTimePoints с isAxis = false
    for (var bookingTime in bookingTimePoints) {
      if (!bookingTime.isBefore(startTime) && !bookingTime.isAfter(endTime)) {
        timeSlots.add(TimePoint(
            isAxis: (((bookingTime.difference(startTime).inMinutes ~/
                                interval.inMinutes) %
                            2 !=
                        0) &&
                    (timeInterval != interval))
                ? false
                : true,
            time: bookingTime));
      }
    }

    // Удаление дубликатов и сортировка
    Set<TimePoint> uniqueTimeSlots = Set<TimePoint>.from(timeSlots);
    List<TimePoint> result = uniqueTimeSlots.toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return result;
  }
}
