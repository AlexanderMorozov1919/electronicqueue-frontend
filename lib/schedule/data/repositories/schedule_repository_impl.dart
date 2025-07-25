import 'dart:async';
import '../../domain/entities/today_schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../models/today_schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  TodayScheduleModel? _cachedSchedule;

  ScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<TodayScheduleEntity> getTodaySchedule() {
    return remoteDataSource.getScheduleUpdates().map((event) {
      if (event is TodayScheduleModel) {
        _cachedSchedule = event;
      } else if (event is ScheduleUpdateDataModel && _cachedSchedule != null) {
        _cachedSchedule = _applyUpdate(_cachedSchedule!, event);
      }
      
      if (_cachedSchedule != null) {
        return _cachedSchedule!;
      } else {
        throw Exception("Schedule stream did not start with initial data.");
      }
    });
  }

  TodayScheduleModel _applyUpdate(TodayScheduleModel current, ScheduleUpdateDataModel update) {
    if (current.date != update.data.date) {
      print("Schedule update ignored: date mismatch. Current: ${current.date}, Update: ${update.data.date}");
      return current;
    }

    if (update.data.doctors.isEmpty) return current;

    final updatedDoctorData = update.data.doctors.first;
    if (updatedDoctorData.slots.isEmpty) return current;
    final updatedSlot = updatedDoctorData.slots.first;
    
    List<DoctorScheduleModel> newDoctorList = current.doctors.cast<DoctorScheduleModel>().toList();
    int doctorIndex = newDoctorList.indexWhere((d) => d.id == updatedDoctorData.id);
    
    if (doctorIndex == -1) {
      if (update.operation == 'insert') {
        newDoctorList.add(DoctorScheduleModel(
          id: updatedDoctorData.id,
          fullName: updatedDoctorData.fullName,
          specialization: updatedDoctorData.specialization,
          slots: [updatedSlot as TimeSlotModel]
        ));
        newDoctorList.sort((a, b) => a.id.compareTo(b.id));
      }
    } else {
      DoctorScheduleModel doctorToUpdate = newDoctorList[doctorIndex];
      List<TimeSlotModel> newSlots = doctorToUpdate.slots.cast<TimeSlotModel>().toList();
      int slotIndex = newSlots.indexWhere((s) => s.startTime == updatedSlot.startTime);

      if (update.operation == 'insert') {
        if (slotIndex == -1) {
          newSlots.add(updatedSlot as TimeSlotModel);
        } else {
           newSlots[slotIndex] = updatedSlot as TimeSlotModel;
        }
      } else if (update.operation == 'update') {
        if (slotIndex != -1) {
          newSlots[slotIndex] = updatedSlot as TimeSlotModel;
        } else {
          newSlots.add(updatedSlot as TimeSlotModel);
        }
      } else if (update.operation == 'delete') {
        if (slotIndex != -1) {
          newSlots.removeAt(slotIndex);
        }
      }

      newSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
      newDoctorList[doctorIndex] = DoctorScheduleModel(
        id: doctorToUpdate.id,
        fullName: doctorToUpdate.fullName,
        specialization: doctorToUpdate.specialization,
        slots: newSlots,
      );
    }
    
    String newMinTime = "23:59:59";
    String newMaxTime = "00:00:00";
    bool hasSlots = false;

    for (var doc in newDoctorList) {
        for (var slot in doc.slots) {
            hasSlots = true;
            if (slot.startTime.compareTo(newMinTime) < 0) newMinTime = slot.startTime;
            if (slot.endTime.compareTo(newMaxTime) > 0) newMaxTime = slot.endTime;
        }
    }
    
    if (!hasSlots) {
        newMinTime = current.minStartTime ?? "09:00:00";
        newMaxTime = current.maxEndTime ?? "18:00:00";
    }

    return TodayScheduleModel(
      date: current.date,
      minStartTime: newMinTime,
      maxEndTime: newMaxTime,
      doctors: newDoctorList,
    );
  }
}