import 'doctor_entity.dart';
import 'schedule_slot_entity.dart';

class DoctorSchedule {
  final DoctorEntity doctor;
  final List<ScheduleSlotEntity> schedule;

  DoctorSchedule({required this.doctor, required this.schedule});
}