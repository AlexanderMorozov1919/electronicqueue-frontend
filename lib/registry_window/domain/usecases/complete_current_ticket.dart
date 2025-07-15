import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/ticket_repository.dart';

class CompleteCurrentTicket {
  final TicketRepository repository;

  CompleteCurrentTicket(this.repository);

  Future<Either<Failure, void>> call(String ticketId) async {
    return await repository.completeCurrentTicket(ticketId);
  }
}