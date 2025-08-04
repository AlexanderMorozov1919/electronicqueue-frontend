import 'package:bloc/bloc.dart';
import 'package:elqueue/administrator/domain/entities/business_process_entity.dart';
import 'package:elqueue/administrator/domain/repositories/settings_repository.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository}) : super(const SettingsState()) {
    on<LoadProcesses>(_onLoadProcesses);
    on<ToggleProcess>(_onToggleProcess);
  }

  Future<void> _onLoadProcesses(
      LoadProcesses event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await settingsRepository.getProcesses();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (processes) => emit(state.copyWith(isLoading: false, processes: processes)),
    );
  }

  Future<void> _onToggleProcess(
      ToggleProcess event, Emitter<SettingsState> emit) async {
    final originalProcesses = List<BusinessProcessEntity>.from(state.processes);
    final processIndex = originalProcesses.indexWhere((p) => p.name == event.processName);
    if(processIndex != -1) {
      final updatedProcess = originalProcesses[processIndex].copyWith(isEnabled: event.isEnabled);
      originalProcesses[processIndex] = updatedProcess;
      emit(state.copyWith(processes: originalProcesses));
    }

    final result = await settingsRepository.updateProcessStatus(event.processName, event.isEnabled);
    result.fold(
      (failure) {
        emit(state.copyWith(error: failure.message, processes: state.processes));
        add(LoadProcesses());
      },
      (_) => {},
    );
  }
}