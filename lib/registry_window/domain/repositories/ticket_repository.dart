import '../entities/ticket_entity.dart';
import '../../core/utils/ticket_category.dart';

abstract class TicketRepository {
  Future<List<TicketEntity>> getTickets();
  Future<TicketEntity?> getCurrentTicket();
  Future<TicketEntity> callNextTicket();
  Future<TicketEntity> registerCurrentTicket();
  Future<TicketEntity> completeCurrentTicket();
  Future<List<TicketEntity>> getTicketsByCategory(TicketCategory category);
}