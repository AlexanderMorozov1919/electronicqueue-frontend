import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/queue_entity.dart';

abstract class QueueRepository {
  Future<Either<Failure, QueueEntity>> getQueueStatus();
  Future<Either<Failure, QueueEntity>> startAppointment(String ticket);
  Future<Either<Failure, QueueEntity>> endAppointment();
}