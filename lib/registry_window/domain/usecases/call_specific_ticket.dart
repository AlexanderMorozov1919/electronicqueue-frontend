import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class CallSpecificTicket {
  final TicketRepository repository;

  CallSpecificTicket(this.repository);

  Future<Either<Failure, TicketEntity>> call(String ticketId, int windowNumber) async {
    return await repository.callSpecificTicket(ticketId, windowNumber);
  }
}