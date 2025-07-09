import '../models/ticket_model.dart';

import '../../domain/entities/ticket_entity.dart';

import '../../core/utils/ticket_category.dart';

abstract class TicketLocalDataSource {
  Future<List<TicketModel>> getTickets();
  Future<TicketModel?> getCurrentTicket();
  Future<TicketModel> callNextTicket();
  Future<TicketModel> registerCurrentTicket();
  Future<TicketModel> completeCurrentTicket();
  Future<List<TicketModel>> getTicketsByCategory(TicketCategory category);
}

class TicketLocalDataSourceImpl implements TicketLocalDataSource {
  final List<TicketModel> _tickets = [
    TicketModel(
      id: '1',
      number: 'A101',
      category: TicketCategory.byAppointment,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    TicketModel(
      id: '2',
      number: 'A102',
      category: TicketCategory.byAppointment,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    TicketModel(
      id: '3',
      number: 'B201',
      category: TicketCategory.makeAppointment,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    TicketModel(
      id: '4',
      number: 'B202',
      category: TicketCategory.makeAppointment,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    TicketModel(
      id: '5',
      number: 'C301',
      category: TicketCategory.tests,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    TicketModel(
      id: '6',
      number: 'C302',
      category: TicketCategory.tests,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    TicketModel(
      id: '7',
      number: 'D401',
      category: TicketCategory.other,
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  TicketModel? _currentTicket;

  @override
  Future<List<TicketModel>> getTickets() async {
    return _tickets;
  }

  @override
  Future<TicketModel?> getCurrentTicket() async {
    return _currentTicket;
  }

  @override
  Future<TicketModel> callNextTicket() async {
    final nextTicket = _tickets.firstWhere(
      (ticket) => !ticket.isCompleted,
      orElse: () => _tickets.last,
    );
    _currentTicket = nextTicket;
    return nextTicket;
  }

  @override
  Future<TicketModel> registerCurrentTicket() async {
    if (_currentTicket == null) {
      throw Exception('No current ticket');
    }
    _currentTicket = _currentTicket!.copyWith(isRegistered: true);
    return _currentTicket!;
  }

  @override
  Future<TicketModel> completeCurrentTicket() async {
    if (_currentTicket == null) {
      throw Exception('No current ticket');
    }
    _currentTicket = _currentTicket!.copyWith(isCompleted: true);
    return _currentTicket!;
  }

  @override
  Future<List<TicketModel>> getTicketsByCategory(TicketCategory category) async {
    return _tickets.where((ticket) => ticket.category == category).toList();
  }
}