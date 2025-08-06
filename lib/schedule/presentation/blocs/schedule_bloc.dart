import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/today_schedule_entity.dart';
import '../../domain/usecases/get_today_schedule.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetTodaySchedule _getTodaySchedule;
  StreamSubscription<TodayScheduleEntity>? _scheduleSubscription;

  ScheduleBloc({required GetTodaySchedule getTodaySchedule})
      : _getTodaySchedule = getTodaySchedule,
        super(ScheduleInitial()) {
    on<SubscribeToScheduleUpdates>(_onSubscribeToScheduleUpdates);
  }

  Future<void> _onSubscribeToScheduleUpdates(
    SubscribeToScheduleUpdates event,
    Emitter<ScheduleState> emit,
  ) async {
    // Если мы еще не загрузили данные, показываем индикатор загрузки
    if (state is! ScheduleLoaded) {
      emit(ScheduleLoading());
    }
    
    _scheduleSubscription?.cancel();

    // Используем emit.forEach для более декларативной обработки потока
    await emit.forEach<TodayScheduleEntity>(
      _getTodaySchedule(),
      onData: (schedule) {
        // При получении новых данных, обновляем состояние и сбрасываем ошибку
        return ScheduleLoaded(schedule, error: null);
      },
      onError: (error, stackTrace) {
        final currentState = state;
        // Если уже есть загруженные данные, показываем их вместе с ошибкой
        if (currentState is ScheduleLoaded) {
          return currentState.copyWith(error: error.toString());
        }
        // Если данных еще нет, показываем полноэкранную ошибку
        return ScheduleError(error.toString());
      },
    );
  }

  @override
  Future<void> close() {
    _scheduleSubscription?.cancel();
    return super.close();
  }
}