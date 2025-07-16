import '../../domain/entities/queue_entity.dart';
import '../models/queue_model.dart';
import '../api/doctor_api.dart';
import 'queue_data_source.dart';

class RemoteQueueDataSource implements QueueDataSource {
  final DoctorApi api;
  int? _currentTicketId; // Сохраняем ID текущего талона

  RemoteQueueDataSource(this.api);

  @override
  Future<QueueEntity> getQueueStatus() async {
    try {
      final queueLength = await api.getRegisteredTicketsCount();
      return QueueModel(
        isAppointmentInProgress: false,
        queueLength: queueLength,
      );
    } catch (e) {
      throw Exception('Failed to get queue status: $e');
    }
  }

  @override
  Future<QueueEntity> startAppointment(String ticket) async {
    try {
      // Получаем список зарегистрированных талонов
      final tickets = await api.getRegisteredTickets();
      
      if (tickets.isEmpty) {
        throw Exception('Нет зарегистрированных талонов');
      }

      // Выбираем талон с наименьшим ID
      tickets.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
      final nextTicket = tickets.first;
      final ticketId = nextTicket['id'] as int;
      final ticketNumber = nextTicket['ticket_number'] as String;

      // Начинаем прием
      final result = await api.startAppointment(ticketId);
      
      // Сохраняем ID текущего талона
      _currentTicketId = ticketId;

      return QueueModel(
        isAppointmentInProgress: true,
        queueLength: 0,
        currentTicket: ticketNumber,
      );
    } catch (e) {
      throw Exception('Failed to start appointment: $e');
    }
  }

  @override
  Future<QueueEntity> endAppointment() async {
    try {
      if (_currentTicketId == null) {
        throw Exception('Нет активного приема');
      }

      // Завершаем прием
      await api.completeAppointment(_currentTicketId!);
      
      // Очищаем ID текущего талона
      _currentTicketId = null;

      return QueueModel(
        isAppointmentInProgress: false,
        queueLength: 0,
      );
    } catch (e) {
      throw Exception('Failed to end appointment: $e');
    }
  }
} 