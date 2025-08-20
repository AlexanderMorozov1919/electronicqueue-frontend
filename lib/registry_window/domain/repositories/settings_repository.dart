import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, bool>> isProcessEnabled(String processName);
}