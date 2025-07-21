import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/doctor_entity.dart';
import '../../../domain/entities/patient_entity.dart';
import '../../../domain/entities/schedule_slot_entity.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../domain/repositories/patient_repository.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository appointmentRepository;
  final PatientRepository patientRepository;

  AppointmentBloc({
    required this.appointmentRepository,
    required this.patientRepository,
  }) : super(AppointmentState()) {
    on<LoadAppointmentInitialData>(_onLoadInitialData);
    on<AppointmentDoctorSelected>(_onDoctorSelected);
    on<AppointmentDateChanged>(_onDateChanged);
    on<_InternalLoadScheduleEvent>(_onInternalLoadSchedule);
    on<CreatePatient>(_onCreatePatient);
    on<SelectPatient>(_onSelectPatient);
    on<SubmitAppointment>(_onSubmit);
  }

  Future<void> _onLoadInitialData(
      LoadAppointmentInitialData event, Emitter<AppointmentState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, submissionSuccess: false, clearDoctor: true, clearPatient: true, schedule: []));
    final doctorsResult = await appointmentRepository.getActiveDoctors();
    doctorsResult.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (doctors) => emit(state.copyWith(isLoading: false, doctors: doctors)),
    );
  }

  void _onDoctorSelected(
      AppointmentDoctorSelected event, Emitter<AppointmentState> emit) {
    if (event.doctor == null) {
      emit(state.copyWith(clearDoctor: true, schedule: []));
      return;
    }
    emit(state.copyWith(selectedDoctor: event.doctor, schedule: []));
    add(const _InternalLoadScheduleEvent());
  }

  void _onDateChanged(
      AppointmentDateChanged event, Emitter<AppointmentState> emit) {
    emit(state.copyWith(selectedDate: event.date, schedule: []));
    add(const _InternalLoadScheduleEvent());
  }

   Future<void> _onCreatePatient(
      CreatePatient event, Emitter<AppointmentState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await patientRepository.createPatient(event.patientData);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (patient) {
        emit(state.copyWith(
          isLoading: false,
          selectedPatient: patient,
        ));
      },
    );
  }
  
  void _onSelectPatient(SelectPatient event, Emitter<AppointmentState> emit) {
    emit(state.copyWith(selectedPatient: event.patient));
  }

  Future<void> _onInternalLoadSchedule(
      _InternalLoadScheduleEvent event, Emitter<AppointmentState> emit) async {
    if (state.selectedDoctor == null) return;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(state.selectedDate);
      final scheduleResult = await appointmentRepository.getDoctorSchedule(
          state.selectedDoctor!.id, dateString);

      scheduleResult.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (schedule) => emit(state.copyWith(isLoading: false, schedule: schedule)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Произошла непредвиденная ошибка: ${e.toString()}'));
    }
  }

  Future<void> _onSubmit(SubmitAppointment event, Emitter<AppointmentState> emit) async {
    if (state.selectedPatient == null) {
      emit(state.copyWith(error: "Пациент не выбран"));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true, submissionSuccess: false));
    final result = await appointmentRepository.createAppointment(
        scheduleId: event.scheduleId,
        patientId: state.selectedPatient!.id,
        ticketId: event.ticketId);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, submissionSuccess: true)),
    );
  }
}