import '../../domain/repositories/schedule_repository.dart';
import '../../domain/entities/today_schedule_entity.dart';

class GetTodaySchedule {
  final ScheduleRepository repository;

  GetTodaySchedule(this.repository);

  Stream<TodayScheduleEntity> call() {
    return repository.getTodaySchedule();
  }
}