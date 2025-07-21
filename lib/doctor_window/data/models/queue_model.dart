import '../../domain/entities/queue_entity.dart';

class QueueModel extends QueueEntity {
  const QueueModel({
    required super.isAppointmentInProgress,
    required super.queueLength,
    required super.isOnBreak,
    super.currentTicket,
    super.activeTicketId,
  });
}