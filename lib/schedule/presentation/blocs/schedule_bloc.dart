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
    on<_ScheduleUpdated>(_onScheduleUpdated);
    on<_ScheduleErrorOccurred>(_onScheduleErrorOccurred);
  }

  void _onSubscribeToScheduleUpdates(
    SubscribeToScheduleUpdates event,
    Emitter<ScheduleState> emit,
  ) {
    emit(ScheduleLoading());
    _scheduleSubscription?.cancel();
    _scheduleSubscription = _getTodaySchedule().listen(
      (schedule) {
        add(_ScheduleUpdated(schedule));
      },
      onError: (error) {
        add(_ScheduleErrorOccurred(error.toString()));
      },
    );
  }
  
  void _onScheduleUpdated(
    _ScheduleUpdated event,
    Emitter<ScheduleState> emit,
  ) {
    emit(ScheduleLoaded(event.schedule));
  }

  void _onScheduleErrorOccurred(
    _ScheduleErrorOccurred event,
    Emitter<ScheduleState> emit,
  ) {
    emit(ScheduleError(event.message));
  }

  @override
  Future<void> close() {
    _scheduleSubscription?.cancel();
    return super.close();
  }
}