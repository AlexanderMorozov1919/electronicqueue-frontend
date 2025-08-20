import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/registrar_repository.dart';
import '../datasources/registrar_remote_data_source.dart';

class RegistrarRepositoryImpl implements RegistrarRepository {
  final RegistrarRemoteDataSource remoteDataSource;

  RegistrarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ServiceEntity>>> getAllServices() async {
    try {
      final services = await remoteDataSource.getAllServices();
      return Right(services);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getPriorities() async {
    try {
      final services = await remoteDataSource.getPriorities();
      return Right(services);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setPriorities(List<int> serviceIds) async {
    try {
      await remoteDataSource.setPriorities(serviceIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}