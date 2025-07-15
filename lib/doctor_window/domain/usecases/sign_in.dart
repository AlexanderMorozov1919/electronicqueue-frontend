import 'package:dartz/dartz.dart';

import '../entities/auth_entity.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<Either<Failure, Doctor>> call(AuthCredentials credentials) async {
    return await repository.signIn(credentials);
  }
}