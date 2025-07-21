import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/waiting_screen_entity.dart';
import '../../domain/repositories/waiting_screen_repository.dart';
import '../../domain/usecases/get_waiting_screen_data.dart';
import 'waiting_screen_event.dart';
import 'waiting_screen_state.dart';

class WaitingScreenBloc extends Bloc<WaitingScreenEvent, WaitingScreenState> {
  final GetWaitingScreenData _getWaitingScreenData;
  final WaitingScreenRepository _repository;

  WaitingScreenBloc({
    required GetWaitingScreenData getWaitingScreenData,
    required WaitingScreenRepository repository,
  })  : _getWaitingScreenData = getWaitingScreenData,
        _repository = repository,
        super(WaitingScreenInitial()) {
    on<InitializeCabinetSelection>(_onInitializeCabinetSelection);
    on<FilterCabinets>(_onFilterCabinets);
    on<LoadWaitingScreen>(_onLoadWaitingScreen);
  }

  Future<void> _onInitializeCabinetSelection(
    InitializeCabinetSelection event,
    Emitter<WaitingScreenState> emit,
  ) async {
    emit(WaitingScreenLoading());
    try {
      final cabinets = await _repository.getActiveCabinets();
      emit(CabinetSelection(allCabinets: cabinets, filteredCabinets: cabinets));
    } catch (e) {
      emit(WaitingScreenError(message: e.toString()));
    }
  }

  void _onFilterCabinets(
    FilterCabinets event,
    Emitter<WaitingScreenState> emit,
  ) {
    final currentState = state;
    if (currentState is CabinetSelection) {
      final filteredList = currentState.allCabinets
          .where((cabinet) => cabinet.toString().contains(event.query))
          .toList();
      emit(currentState.copyWith(filteredCabinets: filteredList));
    }
  }

  void _onLoadWaitingScreen(
    LoadWaitingScreen event,
    Emitter<WaitingScreenState> emit,
  ) async {
    await emit.forEach<WaitingScreenEntity>(
      _getWaitingScreenData(
          GetWaitingScreenDataParams(cabinetNumber: event.cabinetNumber)),
      onData: (entity) {
        // 1. Проверяем, есть ли специальное сообщение от сервера (например, "нет приема")
        if (entity.message != null && entity.message!.isNotEmpty) {
          return WaitingScreenNoReception(message: entity.message!);
        }
        
        // 2. Если сообщения нет, проверяем, вызван ли кто-то
        if (entity.isCalled) {
          return WaitingScreenCalled(
            doctorName: entity.doctorName,
            doctorSpecialty: entity.doctorSpecialty,
            cabinetNumber: entity.cabinetNumber,
            ticketNumber: entity.currentTicket ?? '',
          );
        } else {
          // 3. Иначе - состояние ожидания
          return WaitingScreenWaiting(
            doctorName: entity.doctorName,
            doctorSpecialty: entity.doctorSpecialty,
            cabinetNumber: entity.cabinetNumber,
          );
        }
      },
      onError: (error, stackTrace) =>
          WaitingScreenError(message: error.toString()),
    );
  }
}