part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();
  @override
  List<Object?> get props => [];
}

// Загружает начальные данные для формы (список врачей).
class LoadAppointmentInitialData extends AppointmentEvent {
  const LoadAppointmentInitialData();
}

// Вызывается при выборе специализации из выпадающего списка.
class AppointmentSpecializationSelected extends AppointmentEvent {
  final String? specialization;
  const AppointmentSpecializationSelected(this.specialization);
  @override
  List<Object?> get props => [specialization];
}

// Вызывается при выборе врача из выпадающего списка.
class AppointmentDoctorSelected extends AppointmentEvent {
  final DoctorEntity? doctor;
  const AppointmentDoctorSelected(this.doctor);
  @override
  List<Object?> get props => [doctor];
}

// Вызывается при изменении даты в календаре.
class AppointmentDateChanged extends AppointmentEvent {
  final DateTime date;
  const AppointmentDateChanged(this.date);
  @override
  List<Object> get props => [date];
}

// Внутреннее событие для запуска загрузки расписания (не вызывается из UI напрямую).
class _InternalLoadScheduleEvent extends AppointmentEvent {
  const _InternalLoadScheduleEvent();
}

// Создает нового пациента.
class CreatePatient extends AppointmentEvent {
  final Map<String, dynamic> patientData;
  const CreatePatient(this.patientData);
  @override
  List<Object> get props => [patientData];
}

// Выбирает пациента из результатов поиска или сбрасывает выбор.
class SelectPatient extends AppointmentEvent {
  final PatientEntity? patient;
  const SelectPatient(this.patient);
  @override
  List<Object?> get props => [patient];
}

// Создает новую запись на прием (связанную с текущим талоном).
class SubmitAppointment extends AppointmentEvent {
  final int scheduleId;
  final int ticketId;

  const SubmitAppointment({
    required this.scheduleId,
    required this.ticketId,
  });
  @override
  List<Object> get props => [scheduleId, ticketId];
}

// Загружает историю записей для выбранного пациента.
class LoadPatientAppointments extends AppointmentEvent {
  final int patientId;
  const LoadPatientAppointments(this.patientId);
  @override
  List<Object> get props => [patientId];
}

// Удаляет будущую запись на прием.
class DeleteAppointment extends AppointmentEvent {
  final int appointmentId;
  const DeleteAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}

// Подтверждает явку по записи, привязывая к ней текущий талон.
class ConfirmAppointment extends AppointmentEvent {
  final int appointmentId;
  final int ticketId;
  const ConfirmAppointment({required this.appointmentId, required this.ticketId});
  @override
  List<Object> get props => [appointmentId, ticketId];
}

// Внутреннее событие для очистки истории записей при сбросе пациента.
class _ClearPatientAppointments extends AppointmentEvent {
  const _ClearPatientAppointments();
}