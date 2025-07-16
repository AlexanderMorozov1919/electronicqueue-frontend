import '../../domain/entities/queue_entity.dart';
import '../models/queue_model.dart';
import '../api/doctor_api.dart';
import 'queue_data_source.dart';

class RemoteQueueDataSource implements QueueDataSource {
  final DoctorApi api;

  RemoteQueueDataSource(this.api);

  @override
  Future<QueueEntity> getQueueStatus() async {
    try {
      // Проверяем, есть ли активный прием
      final activeTicket = await api.getCurrentActiveTicket();
      
      if (activeTicket != null) {
        // Есть активный прием
        return QueueModel(
          isAppointmentInProgress: true,
          queueLength: 0,
          currentTicket: activeTicket['ticket_number'] as String,
        );
      } else {
        // Нет активного приема, показываем количество в очереди
        final queueLength = await api.getRegisteredTicketsCount();
        return QueueModel(
          isAppointmentInProgress: false,
          queueLength: queueLength,
        );
      }
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
      print('DEBUG: EndAppointment called');
      
      // Получаем текущий активный талон
      final activeTicket = await api.getCurrentActiveTicket();
      
      if (activeTicket == null) {
        throw Exception('Нет активного приема');
      }

      final ticketId = activeTicket['id'] as int;
      print('DEBUG: Found active ticket ID: $ticketId');

      // Завершаем прием
      print('DEBUG: Calling API to complete appointment');
      await api.completeAppointment(ticketId);

      // Получаем актуальное количество зарегистрированных талонов
      print('DEBUG: Getting updated queue length');
      final queueLength = await api.getRegisteredTicketsCount();
      print('DEBUG: Updated queue length: $queueLength');

      return QueueModel(
        isAppointmentInProgress: false,
        queueLength: queueLength,
      );
    } catch (e) {
      print('DEBUG: Error in endAppointment: $e');
      throw Exception('Failed to end appointment: $e');
    }
  }
} 