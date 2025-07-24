import 'package:elqueue/schedule/data/models/today_schedule_model.dart';
import 'package:elqueue/schedule/domain/entities/today_schedule_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../blocs/schedule_bloc.dart';

import '../../core/config/theme_config/app_theme.dart';
import '../../core/config/theme_config/theme_config.dart';

part 'schedule_card.dart';
part 'schedule_actor.dart';
part 'schedule_column.dart';
part 'schedule_head.dart';
part 'schedule_time_column.dart';
part 'schedule_info_card.dart';

// Helper classes to replace the old logic
class TimePoint {
  final DateTime time;
  final bool isAxis;

  TimePoint({required this.time, required this.isAxis});
}

// Dummy class to satisfy ScheduleHead widget requirements, as filtering
// is not implemented in the provided BLoC.
class ScheduleFilter {}

class ScheduleWidget extends StatelessWidget {
  const ScheduleWidget({super.key});

  List<TimePoint> _generateTimePoints(
      String? minTimeStr, String? maxTimeStr, String dateStr) {
    
    // --- НАЧАЛО ИЗМЕНЕНИЙ ---
    // Гарантируем, что используется только часть с датой (YYYY-MM-DD)
    final dateOnly = dateStr.split('T').first;

    // Default times if not provided, используя очищенную дату
    final minTime = minTimeStr != null
        ? DateTime.parse('${dateOnly}T$minTimeStr')
        : DateTime.parse('${dateOnly}T09:00:00');
    final maxTime = maxTimeStr != null
        ? DateTime.parse('${dateOnly}T$maxTimeStr')
        : DateTime.parse('${dateOnly}T18:00:00');
    // --- КОНЕЦ ИЗМЕНЕНИЙ ---

    final List<TimePoint> points = [];
    DateTime currentTime = minTime;

    // Generate points with a 30-minute interval
    while (currentTime.isBefore(maxTime)) {
      points.add(TimePoint(
        time: currentTime,
        isAxis: currentTime.minute == 0, // Major tick on the hour
      ));
      currentTime = currentTime.add(const Duration(minutes: 30));
    }
    // Ensure the very last point is added
    points.add(TimePoint(time: maxTime, isAxis: maxTime.minute == 0));

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleInitial || state is ScheduleLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ScheduleLoaded) {
          final schedule = state.schedule;
          final timePoints = _generateTimePoints(
              schedule.minStartTime, schedule.maxEndTime, schedule.date);

          if (schedule.doctors.isEmpty) {
            return Center(child: Text('На сегодня расписание отсутствует.'));
          }

          return _buildScheduleContent(
              context, schedule, timePoints, ThemeConfig.lightTheme);
        } else if (state is ScheduleError) {
          return Center(
              child:
                  Text('Не удалось загрузить расписание: ${state.message}'));
        } else {
          return const Center(child: Text('Произошла неизвестная ошибка.'));
        }
      },
    );
  }

  Widget _buildScheduleContent(BuildContext context, TodayScheduleEntity schedule,
      List<TimePoint> timePoints, AppTheme appTheme) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScheduleHead(
            appTheme: appTheme,
            currentDate: DateTime.parse(schedule.date),
            onChangeDate: (value) {
              // This logic should be handled by a new event in BLoC if needed
            },
            onFilter: () {},
            recordsNum: 0,
            addFilter: (String filterType, value) {},
            onToogleFilter: () {},
            filter: ScheduleFilter(),
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
                    timePoints: timePoints),
                for (final doctor
                    in schedule.doctors.cast<DoctorScheduleModel>())
                  ScheduleColumn(
                    key: ValueKey('col-${doctor.id}'),
                    appTheme: appTheme,
                    doctorSchedule: doctor,
                    date: schedule.date, // Передаем дату в дочерний виджет
                    sectionHeight: 60,
                    timePoints: timePoints,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}