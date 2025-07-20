part of 'appointment_bloc.dart';

class AppointmentState extends Equatable {
  // Данные для формы
  final List<DoctorEntity> doctors;
  final List<ScheduleSlotEntity> schedule;
  final List<PatientEntity> patientSearchResults;

  // Выбранные значения
  final DoctorEntity? selectedDoctor;
  final PatientEntity? selectedPatient;
  final DateTime selectedDate;
  
  // Состояния UI
  final bool isLoading;
  final String? error;
  final bool submissionSuccess;

  AppointmentState({
    this.doctors = const [],
    this.schedule = const [],
    this.patientSearchResults = const [],
    this.selectedDoctor,
    this.selectedPatient,
    DateTime? selectedDate,
    this.isLoading = false,
    this.error,
    this.submissionSuccess = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AppointmentState copyWith({
    List<DoctorEntity>? doctors,
    List<ScheduleSlotEntity>? schedule,
    List<PatientEntity>? patientSearchResults,
    DoctorEntity? selectedDoctor,
    PatientEntity? selectedPatient,
    DateTime? selectedDate,
    bool? isLoading,
    String? error,
    bool? submissionSuccess,
    bool clearError = false,
    bool clearDoctor = false,
    bool clearPatient = false,
  }) {
    return AppointmentState(
      doctors: doctors ?? this.doctors,
      schedule: schedule ?? this.schedule,
      patientSearchResults: patientSearchResults ?? this.patientSearchResults,
      selectedDoctor: clearDoctor ? null : selectedDoctor ?? this.selectedDoctor,
      selectedPatient: clearPatient ? null : selectedPatient ?? this.selectedPatient,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
    );
  }

  @override
  List<Object?> get props => [
        doctors,
        schedule,
        patientSearchResults,
        selectedDoctor,
        selectedPatient,
        selectedDate,
        isLoading,
        error,
        submissionSuccess
      ];
}