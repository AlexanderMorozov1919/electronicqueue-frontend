import '../entities/booking.dart';

abstract class ScheduleRepository {
  Future<List<Booking>> getSchedule(String date, int orgId);
}
