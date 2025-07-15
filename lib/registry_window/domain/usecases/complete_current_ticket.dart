import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class CompleteCurrentTicket {
  final TicketRepository repository;

  CompleteCurrentTicket(this.repository);

  Future<TicketEntity> call() async {
    return await repository.completeCurrentTicket();
  }
}