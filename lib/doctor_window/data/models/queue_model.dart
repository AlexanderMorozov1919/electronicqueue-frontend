import '../../domain/entities/queue_entity.dart';

class QueueModel extends QueueEntity {
  const QueueModel({
    required super.isAppointmentInProgress,
    required super.queueLength,
    super.currentTicket,
    super.activeTicketId,
  });
}