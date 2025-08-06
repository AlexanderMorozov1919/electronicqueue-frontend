part of 'appointment_bloc.dart';

class AppointmentState extends Equatable {
  // Данные для формы
  final List<DoctorEntity> allDoctors;
  final List<DoctorEntity> filteredDoctors;
  final List<String> specializations;
  final List<ScheduleSlotEntity> schedule;
  final List<PatientEntity> patientSearchResults;

  // Выбранные значения
  final String? selectedSpecialization;
  final DoctorEntity? selectedDoctor;
  final PatientEntity? selectedPatient;
  final DateTime selectedDate;
  
  // Состояния UI
  final bool isLoading;
  final String? error;
  final bool submissionSuccess;

  // Поля для истории записей
  final List<AppointmentDetailsEntity> patientAppointments;
  final bool historyLoading;

  AppointmentState({
    this.allDoctors = const [],
    this.filteredDoctors = const [],
    this.specializations = const [],
    this.schedule = const [],
    this.patientSearchResults = const [],
    this.selectedSpecialization,
    this.selectedDoctor,
    this.selectedPatient,
    DateTime? selectedDate,
    this.isLoading = false,
    this.error,
    this.submissionSuccess = false,
    this.patientAppointments = const [],
    this.historyLoading = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AppointmentState copyWith({
    List<DoctorEntity>? allDoctors,
    List<DoctorEntity>? filteredDoctors,
    List<String>? specializations,
    List<ScheduleSlotEntity>? schedule,
    List<PatientEntity>? patientSearchResults,
    String? selectedSpecialization,
    DoctorEntity? selectedDoctor,
    PatientEntity? selectedPatient,
    DateTime? selectedDate,
    bool? isLoading,
    String? error,
    bool? submissionSuccess,
    bool clearError = false,
    bool clearDoctor = false,
    bool clearPatient = false,
    bool clearSpecialization = false,
    List<AppointmentDetailsEntity>? patientAppointments,
    bool? historyLoading,
  }) {
    return AppointmentState(
      allDoctors: allDoctors ?? this.allDoctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      specializations: specializations ?? this.specializations,
      schedule: schedule ?? this.schedule,
      patientSearchResults: patientSearchResults ?? this.patientSearchResults,
      selectedSpecialization: clearSpecialization ? null : selectedSpecialization ?? this.selectedSpecialization,
      selectedDoctor: clearDoctor ? null : selectedDoctor ?? this.selectedDoctor,
      selectedPatient: clearPatient ? null : selectedPatient ?? this.selectedPatient,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
      patientAppointments: patientAppointments ?? this.patientAppointments,
      historyLoading: historyLoading ?? this.historyLoading,
    );
  }

  @override
  List<Object?> get props => [
        allDoctors,
        filteredDoctors,
        specializations,
        schedule,
        patientSearchResults,
        selectedSpecialization,
        selectedDoctor,
        selectedPatient,
        selectedDate,
        isLoading,
        error,
        submissionSuccess,
        patientAppointments,
        historyLoading,
      ];
}