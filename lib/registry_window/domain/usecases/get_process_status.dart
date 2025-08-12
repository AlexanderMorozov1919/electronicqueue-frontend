import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class GetProcessStatus {
  final SettingsRepository repository;

  GetProcessStatus(this.repository);

  Future<Either<Failure, bool>> call(String processName) async {
    return await repository.isProcessEnabled(processName);
  }
}