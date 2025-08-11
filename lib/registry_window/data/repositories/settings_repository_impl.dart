import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../datasources/settings_remote_data_source.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, bool>> isProcessEnabled(String processName) async {
    try {
      final isEnabled = await remoteDataSource.isProcessEnabled(processName);
      return Right(isEnabled);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}