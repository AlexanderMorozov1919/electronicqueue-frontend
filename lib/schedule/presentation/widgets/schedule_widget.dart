import 'dart:async';
import 'package:elqueue/queue_reception/presentation/blocs/ad_display_bloc.dart';
import 'package:elqueue/schedule/data/models/today_schedule_model.dart';
import 'package:elqueue/schedule/domain/entities/today_schedule_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../blocs/schedule_bloc.dart';

import '../../core/config/theme_config/app_theme.dart';
import '../../core/config/theme_config/theme_config.dart';

part 'schedule_card.dart';
part 'schedule_actor.dart';
part 'schedule_column.dart';
part 'schedule_head.dart';
part 'schedule_time_column.dart';
part 'schedule_info_card.dart';

class TimePoint {
  final DateTime time;
  final bool isAxis;

  TimePoint({required this.time, required this.isAxis});
}

class ScheduleFilter {}

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({super.key});

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  Timer? _timer;
  int _currentPage = 0;
  int _doctorsPerPage = 1;

  @override
  void initState() {
    super.initState();
  }

  void _startTimer(int totalDoctors) {
    _timer?.cancel();

    if (totalDoctors <= _doctorsPerPage) {
      return;
    }

    final totalPages = (totalDoctors / _doctorsPerPage).ceil();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % totalPages;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<TimePoint> _generateTimePoints(
      String? minTimeStr, String? maxTimeStr, String dateStr) {
    final dateOnly = dateStr.split('T').first;

    final minTime = minTimeStr != null
        ? DateTime.parse('${dateOnly}T$minTimeStr')
        : DateTime.parse('${dateOnly}T09:00:00');
    final maxTime = maxTimeStr != null
        ? DateTime.parse('${dateOnly}T$maxTimeStr')
        : DateTime.parse('${dateOnly}T18:00:00');

    final List<TimePoint> points = [];
    DateTime currentTime = minTime;

    while (currentTime.isBefore(maxTime)) {
      points.add(TimePoint(
        time: currentTime,
        isAxis: currentTime.minute == 0,
      ));
      currentTime = currentTime.add(const Duration(minutes: 30));
    }
    points.add(TimePoint(time: maxTime, isAxis: maxTime.minute == 0));

    return points;
  }

  Widget _buildAdArea(AdDisplayState state) {
    if (state.ads.isEmpty) {
      return const SizedBox.shrink();
    }
  
    final currentAd = state.ads[state.currentIndex];
    final borderRadius = BorderRadius.circular(12.0);
  
    return Padding(
      padding: const EdgeInsets.all(16.0),
      // 1. Контейнер для тени и формы
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset.zero, // Тень со всех сторон
            ),
          ],
        ),
        // 2. ClipRRect для обрезки изображения по той же форме
        child: ClipRRect(
          borderRadius: borderRadius,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            // 3. Само изображение
            child: Image.memory(
              currentAd.picture,
              key: ValueKey<int>(state.currentIndex),
              // ИЗМЕНЕНО: Заполняем пространство, обрезая лишнее, чтобы скругление и тень всегда применялись к краям картинки
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.error_outline, size: 50)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme appTheme = ThemeConfig.lightTheme;

    return BlocBuilder<AdDisplayBloc, AdDisplayState>(
      builder: (context, adState) {
        final bool showAds = adState.ads.isNotEmpty;

        return Column(
          children: [
            // 1. Шапка с датой и временем
            BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, scheduleState) {
                final date = (scheduleState is ScheduleLoaded)
                    ? DateTime.parse(scheduleState.schedule.date)
                    : DateTime.now();
                return ScheduleHead(
                  appTheme: appTheme,
                  currentDate: date,
                  onChangeDate: (value) {},
                  onFilter: () {},
                  recordsNum: 0,
                  addFilter: (String filterType, value) {},
                  onToogleFilter: () {},
                  filter: ScheduleFilter(),
                );
              },
            ),
            // 2. Основная область, которая делится на расписание и рекламу
            Expanded(
              child: Row(
                children: [
                  // Левая часть: Расписание
                  Expanded(
                    child: BlocBuilder<ScheduleBloc, ScheduleState>(
                      builder: (context, state) {
                        if (state is ScheduleInitial || state is ScheduleLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ScheduleLoaded) {
                          final schedule = state.schedule;
                          final timePoints = _generateTimePoints(
                              schedule.minStartTime,
                              schedule.maxEndTime,
                              schedule.date);

                          if (schedule.doctors.isEmpty) {
                            return const Center(
                                child: Text('На сегодня расписание отсутствует.'));
                          }
                          return _buildScheduleContent(
                              context, schedule, timePoints, appTheme);
                        } else if (state is ScheduleError) {
                          return Center(
                              child: Text(
                                  'Не удалось загрузить расписание: ${state.message}'));
                        } else {
                          return const Center(
                              child: Text('Произошла неизвестная ошибка.'));
                        }
                      },
                    ),
                  ),

                  // Правая часть: Реклама (если есть)
                  if (showAds)
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: _buildAdArea(adState),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScheduleContent(BuildContext context, TodayScheduleEntity schedule,
      List<TimePoint> timePoints, AppTheme appTheme) {
    const double timeColumnWidth = 70.0;
    const double doctorColumnWidth = 280.0;

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - timeColumnWidth;
          final newDoctorsPerPage =
              max(1, (availableWidth / doctorColumnWidth).floor());

          if (_doctorsPerPage != newDoctorsPerPage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _doctorsPerPage = newDoctorsPerPage;
                  _currentPage = 0;
                });
                _startTimer(schedule.doctors.length);
              }
            });
          } else if (_timer == null &&
              schedule.doctors.length > _doctorsPerPage) {
            _startTimer(schedule.doctors.length);
          }

          final totalDoctors = schedule.doctors.length;
          final startIndex = _currentPage * _doctorsPerPage;

          if (startIndex >= totalDoctors && totalDoctors > 0) {
            _currentPage = 0;
          }

          final effectiveStartIndex = _currentPage * _doctorsPerPage;
          final endIndex =
              min(effectiveStartIndex + _doctorsPerPage, totalDoctors);

          final doctorsToShow =
              (totalDoctors > 0 && effectiveStartIndex < endIndex)
                  ? schedule.doctors.sublist(effectiveStartIndex, endIndex)
                  : <DoctorScheduleEntity>[];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScheduleTimeColumn(
                    appTheme: appTheme,
                    sectionHeight: 60,
                    timePoints: timePoints),
                for (final doctor in doctorsToShow.cast<DoctorScheduleModel>())
                  ScheduleColumn(
                    key: ValueKey('col-${doctor.id}'),
                    appTheme: appTheme,
                    doctorSchedule: doctor,
                    date: schedule.date,
                    sectionHeight: 60,
                    timePoints: timePoints,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}