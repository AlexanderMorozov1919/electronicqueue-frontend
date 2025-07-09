import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/queue_entity.dart';
import '../repositories/queue_repository.dart';

class EndAppointment {
  final QueueRepository repository;

  EndAppointment(this.repository);

  Future<Either<Failure, QueueEntity>> call() async {
    return await repository.endAppointment();
  }
}