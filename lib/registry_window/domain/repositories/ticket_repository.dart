import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/daily_report_row_entity.dart';
import '../entities/ticket_entity.dart';
import '../../core/utils/ticket_category.dart';

abstract class TicketRepository {
  Future<Either<Failure, List<TicketEntity>>> getTickets();
  Future<Either<Failure, List<TicketEntity>>> getTicketsByCategory(TicketCategory category);
  Future<Either<Failure, TicketEntity?>> getCurrentTicket();
  Future<Either<Failure, TicketEntity>> callNextTicket(int windowNumber);
  Future<Either<Failure, void>> registerCurrentTicket(String ticketId);
  Future<Either<Failure, void>> completeCurrentTicket(String ticketId);
  Future<Either<Failure, List<DailyReportRowEntity>>> getDailyReport();
}