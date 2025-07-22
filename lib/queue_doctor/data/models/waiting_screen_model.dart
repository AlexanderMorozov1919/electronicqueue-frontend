import '../../domain/entities/waiting_screen_entity.dart';

// Модель для одного элемента в очереди, с методом fromJson
class DoctorQueueTicketModel extends DoctorQueueTicketEntity {
  const DoctorQueueTicketModel({
    required super.startTime,
    required super.ticketNumber,
    required super.patientFullName,
    required super.status,
  });

  factory DoctorQueueTicketModel.fromJson(Map<String, dynamic> json) {
    return DoctorQueueTicketModel(
      startTime: json['start_time'] as String? ?? '--:--',
      ticketNumber: json['ticket_number'] as String? ?? '?',
      patientFullName:
          json['patient_full_name'] as String? ?? 'Неизвестный пациент',
      status: json['status'] as String? ?? 'неизвестен',
    );
  }
}

// Главная модель, представляющая состояние экрана
class DoctorQueueModel extends DoctorQueueEntity {
  const DoctorQueueModel({
    required super.doctorName,
    required super.doctorSpecialty,
    required super.cabinetNumber,
    required super.queue,
    super.message,
  });

  factory DoctorQueueModel.fromJson(Map<String, dynamic> json) {
    final queueList = (json['queue'] as List<dynamic>?) ?? [];

    return DoctorQueueModel(
      doctorName: json['doctor_name'] as String? ?? '',
      doctorSpecialty: json['doctor_specialty'] as String? ?? '',
      cabinetNumber: json['cabinet_number'] as int,
      queue: queueList
          .map((item) =>
              DoctorQueueTicketModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}