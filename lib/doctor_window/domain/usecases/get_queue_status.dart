import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/queue_entity.dart';
import '../repositories/queue_repository.dart';

class GetQueueStatus {
  final QueueRepository repository;

  GetQueueStatus(this.repository);

  Future<Either<Failure, QueueEntity>> call() async {
    return await repository.getQueueStatus();
  }
}