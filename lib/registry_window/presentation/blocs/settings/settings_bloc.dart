import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/service_entity.dart';
import '../../../domain/usecases/get_all_services.dart';
import '../../../domain/usecases/get_registrar_priorities.dart';
import '../../../domain/usecases/set_registrar_priorities.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAllServices getAllServices;
  final GetRegistrarPriorities getPriorities;
  final SetRegistrarPriorities setPriorities;

  SettingsBloc({
    required this.getAllServices,
    required this.getPriorities,
    required this.setPriorities,
  }) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<TogglePriority>(_onTogglePriority);
    on<SavePriorities>(_onSavePriorities);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true, saveSuccess: false, clearError: true));

    final servicesResult = await getAllServices();
    await servicesResult.fold(
      (failure) async => emit(state.copyWith(isLoading: false, error: failure.message)),
      (services) async {
        final prioritiesResult = await getPriorities();
        prioritiesResult.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (priorities) {
            final priorityIds = priorities.map((p) => p.id).toSet();
            emit(state.copyWith(
              isLoading: false,
              allServices: services,
              selectedServiceIds: priorityIds,
            ));
          },
        );
      },
    );
  }

  void _onTogglePriority(TogglePriority event, Emitter<SettingsState> emit) {
    final newSelection = Set<int>.from(state.selectedServiceIds);
    if (newSelection.contains(event.serviceId)) {
      newSelection.remove(event.serviceId);
    } else {
      newSelection.add(event.serviceId);
    }
    emit(state.copyWith(selectedServiceIds: newSelection));
  }

  Future<void> _onSavePriorities(SavePriorities event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true, saveSuccess: false, clearError: true));
    final result = await setPriorities(state.selectedServiceIds.toList());
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, saveSuccess: true)),
    );
  }
}