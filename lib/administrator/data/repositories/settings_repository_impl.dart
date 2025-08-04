import 'package:dartz/dartz.dart';
import 'package:elqueue/administrator/core/errors/exceptions.dart';
import 'package:elqueue/administrator/core/errors/failures.dart';
import 'package:elqueue/administrator/data/datasource/settings_remote_data_source.dart';
import 'package:elqueue/administrator/domain/entities/business_process_entity.dart';
import 'package:elqueue/administrator/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BusinessProcessEntity>>> getProcesses() async {
    try {
      final processes = await remoteDataSource.getProcesses();
      return Right(processes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateProcessStatus(String name, bool isEnabled) async {
    try {
      await remoteDataSource.updateProcessStatus(name, isEnabled);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}