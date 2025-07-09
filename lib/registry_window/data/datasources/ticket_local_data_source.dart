import '../models/ticket_model.dart';
import '../../core/utils/ticket_category.dart';
import '../api/registry_api.dart'; // <-- ИМПОРТИРУЕМ НАШ API КЛИЕНТ

abstract class TicketLocalDataSource {
  Future<List<TicketModel>> getTickets();
  Future<TicketModel?> getCurrentTicket();
  Future<TicketModel> callNextTicket();
  Future<TicketModel> registerCurrentTicket();
  Future<TicketModel> completeCurrentTicket();
  Future<List<TicketModel>> getTicketsByCategory(TicketCategory category);
}

class TicketLocalDataSourceImpl implements TicketLocalDataSource {
  // НОВАЯ ЗАВИСИМОСТЬ
  final RegistryApi api;

  // ОБНОВЛЕННЫЙ КОНСТРУКТОР
  TicketLocalDataSourceImpl({required this.api});


  // --- ЭТИ ДАННЫЕ И МЕТОДЫ ОСТАЮТСЯ ДЛЯ СОВМЕСТИМОСТИ ---
  // --- ОНИ БУДУТ РАБОТАТЬ ДЛЯ ВСЕГО, КРОМЕ "ВЫЗВАТЬ СЛЕДУЮЩЕГО" ---

  final List<TicketModel> _tickets = [
    TicketModel(
      id: '1',
      number: 'A101',
      category: TicketCategory.byAppointment,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    TicketModel(
      id: '3',
      number: 'B201',
      category: TicketCategory.makeAppointment,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
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

  // --- КОНЕЦ СТАРЫХ МЕТОДОВ ---


  // !!! ВОТ ЗДЕСЬ ПРОИСХОДИТ ИНТЕГРАЦИЯ !!!
  // Мы переписываем только этот метод, чтобы он обращался к API.
  @override
  Future<TicketModel> callNextTicket() async {
    // Вызываем метод API. Номер окна пока захардкодим для простоты.
    final ticketModel = await api.callNextTicket(1);
    
    // Сохраняем полученный с сервера талон как текущий
    _currentTicket = ticketModel;
    
    return ticketModel;
  }
}