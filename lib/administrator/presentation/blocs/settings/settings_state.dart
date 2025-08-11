part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<BusinessProcessEntity> processes;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.processes = const [],
  });
  
  SettingsState copyWith({
    bool? isLoading,
    String? error,
    List<BusinessProcessEntity>? processes,
    bool clearError = false,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      processes: processes ?? this.processes,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, processes];
}