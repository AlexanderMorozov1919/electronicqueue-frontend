import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/ticket_repository.dart';

class RegisterCurrentTicket {
  final TicketRepository repository;

  RegisterCurrentTicket(this.repository);
  
  Future<Either<Failure, void>> call(String ticketId) async {
    return await repository.registerCurrentTicket(ticketId);
  }
}