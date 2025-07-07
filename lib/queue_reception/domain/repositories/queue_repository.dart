import '../../domain/entities/ticket.dart';

abstract class QueueRepository {
  Stream<List<Ticket>> getActiveTickets(); // Стрим активных талонов
}