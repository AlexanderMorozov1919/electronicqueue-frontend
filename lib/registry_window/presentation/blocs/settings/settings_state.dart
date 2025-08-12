part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final List<ServiceEntity> allServices;
  final Set<int> selectedServiceIds;
  final bool isLoading;
  final String? error;
  final bool saveSuccess;

  const SettingsState({
    this.allServices = const [],
    this.selectedServiceIds = const {},
    this.isLoading = false,
    this.error,
    this.saveSuccess = false,
  });

  SettingsState copyWith({
    List<ServiceEntity>? allServices,
    Set<int>? selectedServiceIds,
    bool? isLoading,
    String? error,
    bool? saveSuccess,
    bool clearError = false,
  }) {
    return SettingsState(
      allServices: allServices ?? this.allServices,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  @override
  List<Object?> get props => [allServices, selectedServiceIds, isLoading, error, saveSuccess];
}