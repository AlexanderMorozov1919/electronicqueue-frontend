import 'package:bloc/bloc.dart';
import '../../domain/usecases/end_appointment.dart';
import '../../domain/usecases/get_queue_status.dart';
import '../../domain/usecases/start_appointment.dart';
import '../../core/errors/failures.dart';

import 'queue_event.dart';
import 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final GetQueueStatus getQueueStatus;
  final StartAppointment startAppointment;
  final EndAppointment endAppointment;

  QueueBloc({
    required this.getQueueStatus,
    required this.startAppointment,
    required this.endAppointment,
  }) : super(QueueInitial()) {
    on<LoadQueueEvent>(_onLoadQueue);
    on<StartAppointmentEvent>(_onStartAppointment);
    on<EndAppointmentEvent>(_onEndAppointment);
  }

  Future<void> _onLoadQueue(
    LoadQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await getQueueStatus();
    result.fold(
      (failure) => emit(QueueError(message: _mapFailureToMessage(failure))),
      (queue) => emit(QueueLoaded(queue: queue)),
    );
  }

  Future<void> _onStartAppointment(
    StartAppointmentEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await startAppointment(event.ticket);
    result.fold(
      (failure) => emit(QueueError(message: _mapFailureToMessage(failure))),
      (queue) => emit(QueueLoaded(queue: queue)),
    );
  }

  Future<void> _onEndAppointment(
    EndAppointmentEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await endAppointment();
    result.fold(
      (failure) => emit(QueueError(message: _mapFailureToMessage(failure))),
      (queue) => emit(QueueLoaded(queue: queue)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Ошибка сервера';
      case InvalidInputFailure:
        return 'Некорректные данные';
      default:
        return 'Неизвестная ошибка';
    }
  }
}