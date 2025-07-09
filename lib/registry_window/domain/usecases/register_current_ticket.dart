import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class RegisterCurrentTicket {
  final TicketRepository repository;

  RegisterCurrentTicket(this.repository);

  Future<TicketEntity> call() async {
    return await repository.registerCurrentTicket();
  }
}