import '../../domain/repositories/queue_repository.dart';
import '../datasources/queue_remote_datasource.dart';
import '../../domain/entities/ticket.dart';

class QueueRepositoryImpl implements QueueRepository {

  final SseQueueRemoteDataSource remoteDataSource;

  QueueRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Ticket>> getActiveTickets() {
    return remoteDataSource.getActiveTickets();
  }
}
