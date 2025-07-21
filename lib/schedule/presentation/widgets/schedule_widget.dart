import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
// Импортируются необходимые пакеты для работы с навигацией, состоянием (BLoC), SVG-иконками и темой приложения.

import '../blocs/schedule_bloc.dart';

import '../../domain/entities/booking.dart';

import '../../core/config/theme_config/app_theme.dart';
import '../../core/config/theme_config/theme_config.dart';

part 'schedule_card.dart';
part 'schedule_actor.dart';
part 'schedule_column.dart';
part 'schedule_head.dart';
part 'schedule_time_column.dart';
part 'schedule_info_card.dart';


class ScheduleWidget extends StatefulWidget {
  final Duration? refreshInterval;

  const ScheduleWidget({super.key, this.refreshInterval});

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (widget.refreshInterval != null) {
      _refreshTimer = Timer.periodic(widget.refreshInterval!, (timer) {
        if (mounted) {
          BlocProvider.of<ScheduleBloc>(context).add(RefreshSheduleData());
        }
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleInit) {
          BlocProvider.of<ScheduleBloc>(context).add(BuildSchedule(
              minTimeInterval: Duration(minutes: 5),
              currentTime: now,
              startTime: DateTime(now.year, now.month, now.day, 9, 0),
              endTime: DateTime(now.year, now.month, now.day, 18, 0),
              timeInterval: const Duration(minutes: 60),
              scheduleDay: now));
          // Начальное состояние
          return const Center(child: Text('Initializing...'));
        } else if (state is ScheduleLoading) {
          // Состояние загрузки
          return const Center(child: CircularProgressIndicator());
        } else if (state is ScheduleLoaded) {
          // Состояние с данными
          return _buildScheduleContent(context, state, ThemeConfig.lightTheme);
        } else if (state is ScheduleError) {
          // Обработка неизвестных состояний
          return const Center(child: Text('Error!'));
        } else {
          return const Center(child: Text('Unknown State!'));
        }
      },
    );
  }

  Widget _buildScheduleContent(
      BuildContext context, ScheduleLoaded state, AppTheme appTheme) {
    final recordsNum = _countBottomClasses(state.bookings);

    // 1. Получаем уникальных врачей (по ФИО)
    final doctors = <String, List<Booking>>{};
    for (final booking in state.bookings) {
      final doctor = booking.actor.employeeName ?? 'Неизвестный врач';
      if (!doctors.containsKey(doctor)) {
        doctors[doctor] = [];
      }
      doctors[doctor]!.add(booking);
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScheduleHead(
            appTheme: appTheme,
            currentDate: state.scheduleDay,
            onChangeDate: (value) => {
              BlocProvider.of<ScheduleBloc>(context).add(BuildSchedule(
                  minTimeInterval: const Duration(minutes: 5),
                  currentTime: value,
                  startTime: DateTime(value.year, value.month, value.day, 9, 0),
                  endTime: DateTime(value.year, value.month, value.day, 18, 0),
                  timeInterval: const Duration(minutes: 60),
                  scheduleDay: value))
            },
            onFilter: () {
              BlocProvider.of<ScheduleBloc>(context).add(FilterSchedule());
            },
            recordsNum: recordsNum,
            addFilter: (String filterType, value) {
              BlocProvider.of<ScheduleBloc>(context).add(ToogleFilterItem(
                  filterType: filterType, filterItemValue: value));
            },
            onToogleFilter: () {
              BlocProvider.of<ScheduleBloc>(context).add(ResetFilter());
              BlocProvider.of<ScheduleBloc>(context).add(FilterSchedule());
            },
            filter: state.filter,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScheduleTimeColumn(
                    appTheme: appTheme,
                    sectionHeight: 60,
                    timePoints: state.timePoints),
                // Для каждого врача отдельная колонка
                for (final entry in doctors.entries) ...[
                  ScheduleColumn(
                    appTheme: appTheme,
                    booking: entry.value.first,
                    sectionHeight: 60,
                    timePoints: state.timePoints,
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  int _countBottomClasses(List<Booking> bookings) {
    int totalCount = 0;

    for (var booking in bookings) {
      totalCount += booking.bookingEntities.length;
    }

    return totalCount;
  }
}
