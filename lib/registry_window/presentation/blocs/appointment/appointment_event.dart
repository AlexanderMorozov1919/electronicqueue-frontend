part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();
  @override
  List<Object?> get props => [];
}

class LoadAppointmentInitialData extends AppointmentEvent {}

class AppointmentDoctorSelected extends AppointmentEvent {
  final DoctorEntity? doctor;
  const AppointmentDoctorSelected(this.doctor);
  @override
  List<Object?> get props => [doctor];
}

class AppointmentDateChanged extends AppointmentEvent {
  final DateTime date;
  const AppointmentDateChanged(this.date);
  @override
  List<Object> get props => [date];
}

class _InternalLoadScheduleEvent extends AppointmentEvent {
  const _InternalLoadScheduleEvent();
}

class CreatePatient extends AppointmentEvent {
  final Map<String, dynamic> patientData;
  const CreatePatient(this.patientData);
  @override
  List<Object> get props => [patientData];
}

class SelectPatient extends AppointmentEvent {
  final PatientEntity? patient;
  const SelectPatient(this.patient);
   @override
  List<Object?> get props => [patient];
}

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