import '../../domain/entities/ticket.dart';

class FakeQueueRemoteDataSource {
  Stream<List<Ticket>> getActiveTickets() async* {
    yield [
      Ticket(id: 'A001', status: 'called', window: '2'),
      Ticket(id: 'B002', status: 'waiting'),
      Ticket(id: 'C003', status: 'waiting'),
    ];
    await Future.delayed(const Duration(seconds: 3));
    yield [
      Ticket(id: 'A001', status: 'called', window: '2'),
      Ticket(id: 'B002', status: 'called', window: '1'),
      Ticket(id: 'C003', status: 'waiting'),
    ];
  }
}