import 'package:equatable/equatable.dart';

// Сущность для одного элемента в очереди к врачу
class DoctorQueueTicketEntity extends Equatable {
  final String startTime;
  final String ticketNumber;
  final String patientFullName;
  final String status;

  const DoctorQueueTicketEntity({
    required this.startTime,
    required this.ticketNumber,
    required this.patientFullName,
    required this.status,
  });

  @override
  List<Object?> get props => [startTime, ticketNumber, patientFullName, status];
}

// Главная сущность, представляющая всё состояние экрана
class DoctorQueueEntity extends Equatable {
  final String doctorName;
  final String doctorSpecialty;
  final int cabinetNumber;
  final List<DoctorQueueTicketEntity> queue;
  final String? message;
  final String doctorStatus;

  const DoctorQueueEntity({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.cabinetNumber,
    required this.queue,
    required this.doctorStatus,
    this.message,
  });

  @override
  List<Object?> get props => [
        doctorName,
        doctorSpecialty,
        cabinetNumber,
        queue,
        message,
        doctorStatus,
      ];
}