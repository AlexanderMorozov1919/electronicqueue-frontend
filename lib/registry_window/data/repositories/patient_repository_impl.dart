import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../datasources/patient_remote_data_source.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PatientEntity>>> searchPatients(String query) async {
    try {
      final patients = await remoteDataSource.searchPatients(query);
      return Right(patients);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> createPatient(Map<String, dynamic> patientData) async {
    try {
      final patient = await remoteDataSource.createPatient(patientData);
      return Right(patient);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}