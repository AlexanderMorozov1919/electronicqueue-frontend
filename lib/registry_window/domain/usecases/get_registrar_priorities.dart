import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/registrar_repository.dart';

class GetRegistrarPriorities {
  final RegistrarRepository repository;

  GetRegistrarPriorities(this.repository);

  Future<Either<Failure, List<ServiceEntity>>> call() async {
    return await repository.getPriorities();
  }
}