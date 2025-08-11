import 'package:equatable/equatable.dart';

class TimeSlotEntity extends Equatable {
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int? cabinet;

  const TimeSlotEntity({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.cabinet,
  });

  @override
  List<Object?> get props => [startTime, endTime, isAvailable, cabinet];
}

class DoctorScheduleEntity extends Equatable {
  final int id;
  final String fullName;
  final String specialization;
  final List<TimeSlotEntity> slots;

  const DoctorScheduleEntity({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.slots,
  });

  @override
  List<Object?> get props => [id, fullName, specialization, slots];
}

class TodayScheduleEntity extends Equatable {
  final String date;
  final String? minStartTime;
  final String? maxEndTime;
  final List<DoctorScheduleEntity> doctors;

  const TodayScheduleEntity({
    required this.date,
    required this.minStartTime,
    required this.maxEndTime,
    required this.doctors,
  });

  @override
  List<Object?> get props => [date, minStartTime, maxEndTime, doctors];
}