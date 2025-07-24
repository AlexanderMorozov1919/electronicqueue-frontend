import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/doctor_entity.dart';
import '../entities/schedule_slot_entity.dart';
import '../entities/appointment_details_entity.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<DoctorEntity>>> getActiveDoctors();
  Future<Either<Failure, List<ScheduleSlotEntity>>> getDoctorSchedule(int doctorId, String date);
  Future<Either<Failure, void>> createAppointment({
    required int scheduleId,
    required int patientId,
    required int ticketId,
  });
  Future<Either<Failure, List<AppointmentDetailsEntity>>> getPatientAppointments(int patientId);
  Future<Either<Failure, void>> deleteAppointment(int appointmentId);
  Future<Either<Failure, void>> confirmAppointment({required int appointmentId, required int ticketId});
}