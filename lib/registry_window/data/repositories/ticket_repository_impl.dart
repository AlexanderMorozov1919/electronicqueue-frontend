import '../../domain/repositories/ticket_repository.dart';
import '../../domain/entities/ticket_entity.dart';
import '../datasources/ticket_local_data_source.dart';
import '../../core/utils/ticket_category.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketLocalDataSource localDataSource;

  TicketRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TicketEntity>> getTickets() async {
    final tickets = await localDataSource.getTickets();
    return tickets.map((model) => model.toEntity()).toList();
  }

  @override
  Future<TicketEntity?> getCurrentTicket() async {
    final ticket = await localDataSource.getCurrentTicket();
    return ticket?.toEntity();
  }

  @override
  Future<TicketEntity> callNextTicket() async {
    final ticket = await localDataSource.callNextTicket();
    return ticket.toEntity();
  }

  @override
  Future<TicketEntity> registerCurrentTicket() async {
    final ticket = await localDataSource.registerCurrentTicket();
    return ticket.toEntity();
  }

  @override
  Future<TicketEntity> completeCurrentTicket() async {
    final ticket = await localDataSource.completeCurrentTicket();
    return ticket.toEntity();
  }

  @override
  Future<List<TicketEntity>> getTicketsByCategory(TicketCategory category) async {
    final tickets = await localDataSource.getTicketsByCategory(category);
    return tickets.map((model) => model.toEntity()).toList();
  }
}