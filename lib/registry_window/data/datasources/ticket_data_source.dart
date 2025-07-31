import '../../core/utils/ticket_category.dart';
import '../../domain/entities/daily_report_row_entity.dart';
import '../../domain/entities/ticket_entity.dart';

abstract class TicketDataSource {
  Future<List<TicketEntity>> getTickets();
  Future<TicketEntity?> getCurrentTicket();
  Future<TicketEntity> callNextTicket(int windowNumber);
  Future<void> updateTicketStatus(String ticketId, String status);
  Future<List<TicketEntity>> getTicketsByCategory(TicketCategory category);
  Future<List<DailyReportRowEntity>> getDailyReport();
}