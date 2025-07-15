import 'package:dartz/dartz.dart';

import '../entities/auth_entity.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, Doctor>> signIn(AuthCredentials credentials);
  Future<void> signOut();
}