import 'package:equatable/equatable.dart';

class DailyReportRowEntity extends Equatable {
  final String ticketNumber;
  final String? patientFullName;
  final String? doctorFullName;
  final String? doctorSpecialization;
  final int? cabinetNumber;
  final String? appointmentTime;
  final String status;

  const DailyReportRowEntity({
    required this.ticketNumber,
    this.patientFullName,
    this.doctorFullName,
    this.doctorSpecialization,
    this.cabinetNumber,
    this.appointmentTime,
    required this.status,
  });

  factory DailyReportRowEntity.fromJson(Map<String, dynamic> json) {
    String translatedStatus;
    switch (json['status']) {
      case 'ожидает':
        translatedStatus = 'Ожидание';
        break;
      case 'приглашен':
      case 'зарегистрирован':
      case 'на_приеме':
        translatedStatus = 'На приёме';
        break;
      case 'завершен':
        translatedStatus = 'Завершён';
        break;
      default:
        translatedStatus = json['status'];
    }

    return DailyReportRowEntity(
      ticketNumber: json['ticket_number'] as String,
      patientFullName: json['patient_full_name'] as String?,
      doctorFullName: json['doctor_full_name'] as String?,
      doctorSpecialization: json['doctor_specialization'] as String?,
      cabinetNumber: json['cabinet_number'] as int?,
      appointmentTime: json['appointment_time'] as String?,
      status: translatedStatus,
    );
  }

  @override
  List<Object?> get props => [
        ticketNumber,
        patientFullName,
        doctorFullName,
        doctorSpecialization,
        cabinetNumber,
        appointmentTime,
        status,
      ];
}