import 'package:equatable/equatable.dart';

class AppointmentDetailsEntity extends Equatable {
  final int appointmentId;
  final String date;
  final String startTime;
  final int? cabinet;
  final String doctorName;
  final String doctorSpec;
  final String patientName;
  final String? ticketNumber;
  final bool isFuture;

  const AppointmentDetailsEntity({
    required this.appointmentId,
    required this.date,
    required this.startTime,
    this.cabinet,
    required this.doctorName,
    required this.doctorSpec,
    required this.patientName,
    this.ticketNumber,
    required this.isFuture,
  });

  factory AppointmentDetailsEntity.fromJson(Map<String, dynamic> json) {
    return AppointmentDetailsEntity(
      appointmentId: json['appointment_id'] as int,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      cabinet: json['cabinet'] as int?,
      doctorName: json['doctor_name'] as String,
      doctorSpec: json['doctor_specialization'] as String,
      patientName: json['patient_name'] as String,
      ticketNumber: json['ticket_number'] as String?,
      isFuture: json['is_future'] as bool,
    );
  }

  @override
  List<Object?> get props => [
        appointmentId,
        date,
        startTime,
        cabinet,
        doctorName,
        doctorSpec,
        patientName,
        ticketNumber,
        isFuture,
      ];
}