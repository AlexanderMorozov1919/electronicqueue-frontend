import 'package:equatable/equatable.dart';

class DailyReportRowEntity extends Equatable {
  final String ticketNumber;
  // final String? patientFullName; // УДАЛЕНО
  final String? doctorFullName;
  final String? doctorSpecialization;
  final int? cabinetNumber;
  final String? appointmentTime;
  final String status;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final String? duration;

  const DailyReportRowEntity({
    required this.ticketNumber,
    // this.patientFullName, // УДАЛЕНО
    this.doctorFullName,
    this.doctorSpecialization,
    this.cabinetNumber,
    this.appointmentTime,
    required this.status,
    this.calledAt,
    this.completedAt,
    this.duration,
  });

  factory DailyReportRowEntity.fromJson(Map<String, dynamic> json) {
    return DailyReportRowEntity(
      ticketNumber: json['ticket_number'] as String,
      // patientFullName: json['patient_full_name'] as String?, // УДАЛЕНО
      doctorFullName: json['doctor_full_name'] as String?,
      doctorSpecialization: json['doctor_specialization'] as String?,
      cabinetNumber: json['cabinet_number'] as int?,
      appointmentTime: json['appointment_time'] as String?,
      status: json['status'] as String,
      calledAt: json['called_at'] != null ? DateTime.parse(json['called_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      duration: json['duration'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        ticketNumber,
        // patientFullName, // УДАЛЕНО
        doctorFullName,
        doctorSpecialization,
        cabinetNumber,
        appointmentTime,
        status,
        calledAt,
        completedAt,
        duration,
      ];
}