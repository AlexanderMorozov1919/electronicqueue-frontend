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
  int _verticalCurrentPage = 0;
  int _timeSlotsPerPage = 1;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _advancePage();
      }
    });
  }

  void _advancePage() {
    final scheduleState = context.read<ScheduleBloc>().state;
    if (scheduleState is! ScheduleLoaded) return;
    
    final schedule = scheduleState.schedule;
    final totalDoctors = schedule.doctors.length;

    if (totalDoctors == 0 || _doctorsPerPage <= 0 || _timeSlotsPerPage <= 0) return;

    final totalHorizontalPages = (totalDoctors / _doctorsPerPage).ceil();

    final startIndex = _currentPage * _doctorsPerPage;
    final endIndex = min(startIndex + _doctorsPerPage, totalDoctors);
    final doctorsOnCurrentPage = (totalDoctors > 0 && startIndex < endIndex)
        ? schedule.doctors.sublist(startIndex, endIndex)
        : <DoctorScheduleEntity>[];
    
    final pageTimes = _calculateMinMaxForDoctors(doctorsOnCurrentPage, schedule.date);
    final timePoints = _generateTimePoints(pageTimes.minTime, pageTimes.maxTime);
    final totalTimePoints = timePoints.isNotEmpty ? timePoints.length - 1 : 0;
    final totalVerticalPagesForCurrentPage = max(1, (totalTimePoints / _timeSlotsPerPage).ceil());
    
    if (totalHorizontalPages <= 1 && totalVerticalPagesForCurrentPage <= 1) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    setState(() {
      _verticalCurrentPage++;
      if (_verticalCurrentPage >= totalVerticalPagesForCurrentPage) {
        _verticalCurrentPage = 0;
        _currentPage = (_currentPage + 1) % totalHorizontalPages;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _MinMaxTimes _calculateMinMaxForDoctors(
      List<DoctorScheduleEntity> doctors, String dateStr) {
    if (doctors.isEmpty) {
      final date = DateTime.parse(dateStr);
      return _MinMaxTimes(
        minTime: DateTime(date.year, date.month, date.day, 9),
        maxTime: DateTime(date.year, date.month, date.day, 18),
      );
    }

    DateTime? minTime;
    DateTime? maxTime;
    final dateOnly = dateStr.split('T').first;

    for (var doctor in doctors) {
      for (var slot in doctor.slots) {
        try {
          final slotStart = DateTime.parse('${dateOnly}T${slot.startTime}');
          final slotEnd = DateTime.parse('${dateOnly}T${slot.endTime}');

          if (minTime == null || slotStart.isBefore(minTime)) {
            minTime = slotStart;
          }
          if (maxTime == null || slotEnd.isAfter(maxTime)) {
            maxTime = slotEnd;
          }
        } catch (e) {
          // Игнорируем ошибки парсинга для отказоустойчивости
        }
      }
    }

    if (minTime == null || maxTime == null) {
      final date = DateTime.parse(dateStr);
      return _MinMaxTimes(
        minTime: DateTime(date.year, date.month, date.day, 9),
        maxTime: DateTime(date.year, date.month, date.day, 18),
      );
    }

    return _MinMaxTimes(minTime: minTime, maxTime: maxTime);
  }
  
  List<TimePoint> _generateTimePoints(DateTime minTime, DateTime maxTime) {
    final List<TimePoint> points = [];
    DateTime currentTime = minTime;

    while (currentTime.isBefore(maxTime)) {
      points.add(TimePoint(
        time: currentTime,
        isAxis: currentTime.minute == 0,
      ));
      currentTime = currentTime.add(const Duration(minutes: 30));
    }
    // Добавляем последнюю точку, чтобы замкнуть интервал
    if(points.isEmpty || points.last.time.isBefore(maxTime)) {
       points.add(TimePoint(time: maxTime, isAxis: maxTime.minute == 0));
    }
    
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(38, 0, 0, 0),
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image(
              image: currentAd.picture,
              key: ValueKey<int>(currentAd.id),
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
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: BlocConsumer<ScheduleBloc, ScheduleState>(
                      listener: (context, state) {
                        if (state is ScheduleLoaded && _timer == null) {
                           _startTimer();
                        }
                      },
                      builder: (context, state) {
                        if (state is ScheduleInitial || state is ScheduleLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ScheduleLoaded) {
                          final schedule = state.schedule;
                          if (schedule.doctors.isEmpty) {
                            return const Center(
                                child: Text('На сегодня расписание отсутствует.'));
                          }
                          return _buildScheduleContent(context, schedule, appTheme);
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
      AppTheme appTheme) {
    const double timeColumnWidth = 70.0;
    const double minDoctorColumnWidth = 280.0;
    const double sectionHeight = 60.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // --- 1. РАСЧЕТ ПАРАМЕТРОВ ПАГИНАЦИИ ---
        final availableWidth = constraints.maxWidth - timeColumnWidth;
        final newDoctorsPerPage = max(1, (availableWidth / minDoctorColumnWidth).floor());
        
        // Высота одного слота + отступ
        final availableHeight = constraints.maxHeight - 135; // Вычитаем высоту шапки врача
        final newTimeSlotsPerPage = max(1, (availableHeight / sectionHeight).floor());

        if (_doctorsPerPage != newDoctorsPerPage || _timeSlotsPerPage != newTimeSlotsPerPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _doctorsPerPage = newDoctorsPerPage;
                _timeSlotsPerPage = newTimeSlotsPerPage;
                _currentPage = 0;
                _verticalCurrentPage = 0;
              });
              _startTimer();
            }
          });
        }
        
        // --- 2. ПОЛУЧЕНИЕ ВРАЧЕЙ ДЛЯ ТЕКУЩЕЙ ГОРИЗОНТАЛЬНОЙ СТРАНИЦЫ ---
        final totalDoctors = schedule.doctors.length;
        final totalHorizontalPages = (totalDoctors / _doctorsPerPage).ceil();

        if (_currentPage >= totalHorizontalPages && totalHorizontalPages > 0) {
          _currentPage = 0;
          _verticalCurrentPage = 0;
        }

        final startIndex = _currentPage * _doctorsPerPage;
        final endIndex = min(startIndex + _doctorsPerPage, totalDoctors);
        
        final doctorsToShow = (totalDoctors > 0 && startIndex < endIndex)
            ? schedule.doctors.sublist(startIndex, endIndex)
            : <DoctorScheduleEntity>[];

        final double actualDoctorColumnWidth;
        if (doctorsToShow.isNotEmpty) {
          actualDoctorColumnWidth = availableWidth / doctorsToShow.length;
        } else {
          actualDoctorColumnWidth = minDoctorColumnWidth;
        }
        
        // --- 3. ПОЛУЧЕНИЕ И НАРЕЗКА ВРЕМЕННЫХ ТОЧЕК ---
        final pageTimes = _calculateMinMaxForDoctors(doctorsToShow, schedule.date);
        final fullTimePoints = _generateTimePoints(pageTimes.minTime, pageTimes.maxTime);
        
        final totalTimePoints = fullTimePoints.isNotEmpty ? fullTimePoints.length - 1 : 0;
        final totalVerticalPages = max(1, (totalTimePoints / _timeSlotsPerPage).ceil());
        
        if (_verticalCurrentPage >= totalVerticalPages && totalVerticalPages > 0) {
           _verticalCurrentPage = 0;
        }

        final verticalStartIndex = _verticalCurrentPage * _timeSlotsPerPage;
        final verticalEndIndex = min(verticalStartIndex + _timeSlotsPerPage + 1, fullTimePoints.length);

        final visibleTimePoints = (fullTimePoints.isNotEmpty && verticalStartIndex < verticalEndIndex)
            ? fullTimePoints.sublist(verticalStartIndex, verticalEndIndex)
            : <TimePoint>[];
        
        // --- 4. ПОСТРОЕНИЕ ВИДЖЕТОВ ---
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduleTimeColumn(
                  appTheme: appTheme,
                  sectionHeight: sectionHeight,
                  timePoints: visibleTimePoints),
              for (final doctor in doctorsToShow.cast<DoctorScheduleModel>())
                ScheduleColumn(
                  key: ValueKey('col-${doctor.id}-${_currentPage}-${_verticalCurrentPage}'),
                  appTheme: appTheme,
                  doctorSchedule: doctor,
                  date: schedule.date,
                  sectionHeight: sectionHeight,
                  timePoints: visibleTimePoints,
                  width: actualDoctorColumnWidth,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MinMaxTimes {
  final DateTime minTime;
  final DateTime maxTime;
  _MinMaxTimes({required this.minTime, required this.maxTime});
}