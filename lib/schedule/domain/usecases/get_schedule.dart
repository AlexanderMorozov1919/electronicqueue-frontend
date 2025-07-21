// domain/usecases/get_schedule.dart
import 'package:equatable/equatable.dart';
import '../repositories/schedule_repository.dart';
import '../entities/booking.dart';

class GetSchedule extends Equatable {
  final ScheduleRepository repository;

  GetSchedule(this.repository);

  Future<List<Booking>> execute(String date, int orgId) async {
    return await repository.getSchedule(date, orgId);
  }

  @override
  List<Object?> get props => [];
}
