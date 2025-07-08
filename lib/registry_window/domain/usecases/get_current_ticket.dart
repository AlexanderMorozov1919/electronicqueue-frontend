import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class GetCurrentTicket {
  final TicketRepository repository;

  GetCurrentTicket(this.repository);

  Future<TicketEntity?> call() async {
    return await repository.getCurrentTicket();
  }
}