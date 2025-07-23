import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_actor.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  ScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Booking>> getSchedule(String date, int orgId) async {
    final doctors = await remoteDataSource.getActiveDoctors();

    final scheduleFutures = doctors.map((doctor) {
      return remoteDataSource.getDoctorSchedule(doctor.id, date);
    }).toList();

    final schedules = await Future.wait(scheduleFutures);

    final List<Booking> bookings = [];
    for (int i = 0; i < doctors.length; i++) {
      final doctor = doctors[i];
      final scheduleSlots = schedules[i];

      // Пропускаем врачей, у которых нет расписания на этот день
      if (scheduleSlots.isEmpty) continue;

      final bookingEntities = scheduleSlots.map((slot) {
        return BookingEntity(
          id: slot.id, 
          startTime: slot.startTime,
          endTime: slot.endTime,
          status: slot.isAvailable ? 8 : 2,  // :-) 
        );
      }).toList();
      
      final dayStartTime = scheduleSlots.first.startTime;
      final dayEndTime = scheduleSlots.last.endTime;

      bookings.add(
        Booking(
          actor: BookingActor(
            branchId: doctor.id, 
            branchName: doctor.specialization,
            employeeId: doctor.id,
            employeeName: doctor.fullName,
            equipmentId: doctor.id,
            equipmentName: 'Кабинет ${doctor.id + 100}', 
            equipmentType: 'Врач',
          ),
          bookingEntities: bookingEntities,
          startTime: dayStartTime,
          endTime: dayEndTime,
        ),
      );
    }
    return bookings;
  }
}