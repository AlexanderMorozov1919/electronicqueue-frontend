import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/usecases/end_appointment.dart';
import '../../domain/usecases/get_queue_status.dart';
import '../../domain/usecases/start_appointment.dart';
import '../../domain/usecases/watch_queue_updates.dart';
import '../../core/errors/failures.dart';
import '../../domain/usecases/end_break.dart';
import '../../domain/usecases/start_break.dart';

import 'queue_event.dart';
import 'queue_state.dart';

class _QueueUpdateReceivedEvent extends QueueEvent {}

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final GetQueueStatus getQueueStatus;
  final StartAppointment startAppointment;
  final EndAppointment endAppointment;
  final WatchQueueUpdates watchQueueUpdates;
  final StartBreak startBreak; 
  final EndBreak endBreak; 

  StreamSubscription? _queueUpdatesSubscription;

  QueueBloc({
    required this.getQueueStatus,
    required this.startAppointment,
    required this.endAppointment,
    required this.watchQueueUpdates,
    required this.startBreak, 
    required this.endBreak,
  }) : super(QueueInitial()) {
    on<LoadQueueEvent>(_onLoadQueue);
    on<StartAppointmentEvent>(_onStartAppointment);
    on<EndAppointmentEvent>(_onEndAppointment);
    on<_QueueUpdateReceivedEvent>(_onQueueUpdateReceived);
    on<StartBreakEvent>(_onStartBreak);
    on<EndBreakEvent>(_onEndBreak); 

    _startWatchingUpdates();
  }

  void _startWatchingUpdates() {
    _queueUpdatesSubscription?.cancel();
    _queueUpdatesSubscription = watchQueueUpdates().listen((_) {
      add(_QueueUpdateReceivedEvent());
    });
  }

  void _onQueueUpdateReceived(
    _QueueUpdateReceivedEvent event,
    Emitter<QueueState> emit,
  ) {
    print("BLoC: Received queue update, reloading status...");
    add(LoadQueueEvent());
  }

  Future<void> _onLoadQueue(
    LoadQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    if (state is! QueueLoaded) {
      emit(QueueLoading());
    }
    final result = await getQueueStatus();
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (queue) => emit(QueueLoaded(queue: queue)),
    );
  }

  Future<void> _onStartAppointment(
    StartAppointmentEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await startAppointment();
    result.fold((failure) {
      if (failure is EmptyQueueFailure) {
        getQueueStatus().then((statusResult) {
          statusResult.fold(
            (f) => emit(QueueError(message: f.message)),
            (q) => emit(QueueLoaded(queue: q, infoMessage: failure.message)),
          );
        });
      } else {
        emit(QueueError(message: failure.message));
      }
    }, (_) => add(LoadQueueEvent()));
  }

  Future<void> _onEndAppointment(
    EndAppointmentEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await endAppointment();
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (_) => add(LoadQueueEvent()),
    );
  }

  Future<void> _onStartBreak(
    StartBreakEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await startBreak();
    result.fold(
      (failure) => emit(QueueError(message: 'Не удалось начать перерыв')),
      (queue) => emit(QueueLoaded(queue: queue, infoMessage: 'Перерыв начат')),
    );
  }

   Future<void> _onEndBreak(
    EndBreakEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await endBreak();
    result.fold(
      (failure) => emit(QueueError(message: 'Не удалось завершить перерыв')),
      (queue) => emit(QueueLoaded(queue: queue, infoMessage: 'Перерыв завершен')),
    );
  }

  @override
  Future<void> close() {
    _queueUpdatesSubscription?.cancel();
    return super.close();
  }
}
