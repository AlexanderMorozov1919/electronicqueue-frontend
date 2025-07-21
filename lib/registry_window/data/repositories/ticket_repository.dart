import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../core/utils/ticket_category.dart';

abstract class TicketRepository {
  Future<Either<Failure, List<TicketEntity>>> getTickets();
  Future<Either<Failure, TicketEntity?>> getCurrentTicket();
  Future<Either<Failure, TicketEntity>> callNextTicket(int windowNumber);
  Future<Either<Failure, void>> registerCurrentTicket(String ticketId);
  Future<Either<Failure, void>> completeCurrentTicket(String ticketId);
  Future<Either<Failure, List<TicketEntity>>> getTicketsByCategory(TicketCategory category);
}