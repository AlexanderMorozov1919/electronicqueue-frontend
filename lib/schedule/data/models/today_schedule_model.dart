import '../../domain/entities/today_schedule_entity.dart';

class TimeSlotModel extends TimeSlotEntity {
  const TimeSlotModel({
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
    super.cabinet,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isAvailable: json['is_available'] as bool,
      cabinet: json['cabinet'] as int?,
    );
  }
}

class DoctorScheduleModel extends DoctorScheduleEntity {
  const DoctorScheduleModel({
    required super.id,
    required super.fullName,
    required super.specialization,
    required super.slots,
  });

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    var slotsList = json['slots'] as List;
    List<TimeSlotModel> slots =
        slotsList.map((i) => TimeSlotModel.fromJson(i)).toList();

    return DoctorScheduleModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      specialization: json['specialization'] as String,
      slots: slots,
    );
  }
}


class TodayScheduleModel extends TodayScheduleEntity {
  const TodayScheduleModel({
    required super.date,
    super.minStartTime,
    super.maxEndTime,
    required super.doctors,
  });

  factory TodayScheduleModel.fromJson(Map<String, dynamic> json) {
    var doctorsList = json['doctors'] as List;
    List<DoctorScheduleModel> doctors =
        doctorsList.map((i) => DoctorScheduleModel.fromJson(i)).toList();

    return TodayScheduleModel(
      date: json['date'] as String,
      minStartTime: json['min_start_time'] as String?,
      maxEndTime: json['max_end_time'] as String?,
      doctors: doctors,
    );
  }
}

class ScheduleUpdateDataModel {
  final String operation;
  final TodayScheduleModel data;

  ScheduleUpdateDataModel({required this.operation, required this.data});

  factory ScheduleUpdateDataModel.fromJson(Map<String, dynamic> json) {
    return ScheduleUpdateDataModel(
      operation: json['operation'] as String,
      // 'data' в событии обновления содержит только затронутые элементы
      data: TodayScheduleModel.fromJson(json['data']),
    );
  }
}