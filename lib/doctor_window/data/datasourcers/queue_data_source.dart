import '../../domain/entities/queue_entity.dart';

abstract class QueueDataSource {
  Future<QueueEntity> getQueueStatus();
  Future<QueueEntity> startAppointment(String ticket);
  Future<QueueEntity> endAppointment();
}