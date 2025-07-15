import 'package:dartz/dartz.dart';

import '../../domain/entities/auth_entity.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasourcers/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Doctor>> signIn(AuthCredentials credentials) async {
    try {
      final doctor = await localDataSource.signIn(credentials);
      return Right(doctor);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<void> signOut() async {
    await localDataSource.signOut();
  }
}