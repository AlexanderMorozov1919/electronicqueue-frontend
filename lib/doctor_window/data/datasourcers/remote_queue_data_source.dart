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
      final queueLength = await api.getRegisteredTicketsCount();
      return QueueModel(
        isAppointmentInProgress: false, // Пока оставляем как есть
        queueLength: queueLength,
      );
    } catch (e) {
      throw Exception('Failed to get queue status: $e');
    }
  }

  @override
  Future<QueueEntity> startAppointment(String ticket) async {
    // Пока оставляем заглушку
    return QueueModel(
      isAppointmentInProgress: true,
      queueLength: 0,
      currentTicket: ticket,
    );
  }

  @override
  Future<QueueEntity> endAppointment() async {
    // Пока оставляем заглушку
    return QueueModel(
      isAppointmentInProgress: false,
      queueLength: 0,
    );
  }
} 