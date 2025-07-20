import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/patient_entity.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<PatientEntity>>> searchPatients(String query);
  Future<Either<Failure, PatientEntity>> createPatient(Map<String, dynamic> patientData);
}