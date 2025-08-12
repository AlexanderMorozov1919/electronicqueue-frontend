import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/service_entity.dart';

abstract class RegistrarRepository {
  Future<Either<Failure, List<ServiceEntity>>> getAllServices();
  Future<Either<Failure, List<ServiceEntity>>> getPriorities();
  Future<Either<Failure, void>> setPriorities(List<int> serviceIds);
}