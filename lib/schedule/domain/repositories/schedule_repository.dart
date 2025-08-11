import 'package:elqueue/schedule/domain/entities/today_schedule_entity.dart';

abstract class ScheduleRepository {
  Stream<TodayScheduleEntity> getTodaySchedule();
}