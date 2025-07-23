import 'package:equatable/equatable.dart';

class ScheduleSlotEntity extends Equatable {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? patientName; 

  const ScheduleSlotEntity({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.patientName,
  });

  factory ScheduleSlotEntity.fromJson(Map<String, dynamic> json) {
    final String datePart = (json['date'] as String).substring(0, 10);
    final String startTimeString = json['start_time'] as String;
    final String endTimeString = json['end_time'] as String;

    final DateTime finalStartTime = DateTime.parse('${datePart}T$startTimeString');
    final DateTime finalEndTime = DateTime.parse('${datePart}T$endTimeString');

    final appointmentData = json['appointment'] as Map<String, dynamic>?;
    final patientData = appointmentData?['patient'] as Map<String, dynamic>?;

    return ScheduleSlotEntity(
      id: json['schedule_id'] as int,
      startTime: finalStartTime,
      endTime: finalEndTime,
      isAvailable: json['is_available'] as bool,
      patientName: patientData?['full_name'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, startTime, endTime, isAvailable, patientName];
}