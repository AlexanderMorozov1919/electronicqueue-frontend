import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/queue_repository.dart';

class WatchQueueUpdates {
  final QueueRepository repository;

  WatchQueueUpdates(this.repository);

  Stream<Either<Failure, void>> call() {
    return repository.ticketUpdates();
  }
}
