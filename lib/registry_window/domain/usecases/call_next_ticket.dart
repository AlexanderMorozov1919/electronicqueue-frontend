import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class CallNextTicket {
  final TicketRepository repository;

  CallNextTicket(this.repository);

  Future<TicketEntity> call() async {
    return await repository.callNextTicket();
  }
}