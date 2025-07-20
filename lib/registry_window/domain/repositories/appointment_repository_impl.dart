import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/appointment_remote_data_source.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/schedule_slot_entity.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, List<DoctorEntity>>> getActiveDoctors() async {
    try {
      final doctors = await remoteDataSource.getActiveDoctors();
      return Right(doctors);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch(e) {
      return Left(ServerFailure('Непредвиденная ошибка: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleSlotEntity>>> getDoctorSchedule(int doctorId, String date) async {
     try {
      final schedule = await remoteDataSource.getDoctorSchedule(doctorId, date);
      return Right(schedule);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch(e) {
      return Left(ServerFailure('Непредвиденная ошибка: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createAppointment({required int scheduleId, required int patientId, required int ticketId}) async {
    try {
      await remoteDataSource.createAppointment(scheduleId: scheduleId, patientId: patientId, ticketId: ticketId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch(e) {
      return Left(ServerFailure('Непредвиденная ошибка: ${e.toString()}'));
    }
  }
}