import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/registrar_repository.dart';

class SetRegistrarPriorities {
  final RegistrarRepository repository;

  SetRegistrarPriorities(this.repository);

  Future<Either<Failure, void>> call(List<int> serviceIds) async {
    return await repository.setPriorities(serviceIds);
  }
}