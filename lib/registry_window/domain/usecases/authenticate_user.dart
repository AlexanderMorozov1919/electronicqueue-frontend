import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class AuthenticateUser {
  final AuthRepository repository;

  AuthenticateUser(this.repository);

  Future<Either<Failure, bool>> call(AuthEntity authEntity) async {
    return await repository.authenticate(authEntity);
  }
}