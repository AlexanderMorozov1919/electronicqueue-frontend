import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_actor.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/entities/booking_entity.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  @override
  Future<List<Booking>> getSchedule(String date, int orgId) async {
    final doctorIvanov = BookingActor(
      branchId: 1,
      branchName: 'Терапевт',
      employeeId: 1,
      employeeName: 'Иванов И.И.',
      equipmentId: 1,
      equipmentName: 'Кабинет 1',
      equipmentType: 'Врач',
    );
    final doctorPetrov = BookingActor(
      branchId: 2,
      branchName: 'Хирург',
      employeeId: 2,
      employeeName: 'Петров П.П.',
      equipmentId: 2,
      equipmentName: 'Кабинет 2',
      equipmentType: 'Врач',
    );
    return [
      Booking(
        startTime: DateTime.parse('$date 09:00:00'),
        endTime: DateTime.parse('$date 15:00:00'), // Полный рабочий день
        bookingEntities: [
          BookingEntity(
            id: 1,
            startTime: DateTime.parse('$date 09:30:00'), // Четко внутри слота 09:00-10:00
            endTime: DateTime.parse('$date 10:00:00'),
            status: 2,
          ),
          BookingEntity(
            id: 2,
            startTime: DateTime.parse('$date 11:00:00'), // Четко внутри слота 11:00-12:00
            endTime: DateTime.parse('$date 11:30:00'),
            status: 8,
          ),
        ],
        actor: doctorIvanov,
      ),
      Booking(
        startTime: DateTime.parse('$date 10:00:00'),
        endTime: DateTime.parse('$date 11:00:00'),
        bookingEntities: [],
        actor: doctorPetrov,
      ),
      Booking(
        startTime: DateTime.parse('$date 13:00:00'),
        endTime: DateTime.parse('$date 14:00:00'),
        bookingEntities: [],
        actor: doctorPetrov,
      ),
    ];
  }
}
