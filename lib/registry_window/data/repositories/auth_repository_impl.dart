import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, bool>> authenticate(AuthEntity authEntity) async {
    if (authEntity.login == 'admin' && authEntity.password == 'admin') {
      return const Right(true);
    } else {
      return Left(ServerFailure('Неверный логин или пароль'));
    }
  }
}