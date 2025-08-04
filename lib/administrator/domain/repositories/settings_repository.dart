import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/business_process_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, List<BusinessProcessEntity>>> getProcesses();
  Future<Either<Failure, void>> updateProcessStatus(String name, bool isEnabled);
}