import 'package:dartz/dartz.dart';

import '../../domain/entities/auth_entity.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasourcers/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Doctor>> signIn(AuthCredentials credentials) async {
    try {
      final doctor = await remoteDataSource.signIn(credentials);
      return Right(doctor);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
