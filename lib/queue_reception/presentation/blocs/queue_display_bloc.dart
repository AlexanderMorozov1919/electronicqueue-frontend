import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../presentation/blocs/queue_display_event.dart';
import '../blocs/queue_display_state.dart';
import '../../domain/entities/ticket.dart';
import '../../services/audio_service.dart';

class QueueDisplayBloc extends Bloc<QueueDisplayEvent, QueueDisplayState> {
  final QueueRepository repository;
  final AudioService _audioService = AudioService();
  
  // Для отслеживания предыдущего состояния
  List<Ticket> _previousTickets = [];

  QueueDisplayBloc(this.repository) : super(const QueueDisplayInitial()) {
    on<LoadTicketsEvent>((event, emit) async {
      emit(QueueDisplayLoading());
      try {
        final ticketStream = repository.getActiveTickets();

        await emit.forEach<List<Ticket>>(
          ticketStream,
          onData: (tickets) {
            _handleTicketUpdates(tickets);
            _previousTickets = List.from(tickets);
            return QueueDisplayLoaded(tickets);
          },
          onError: (error, stackTrace) => QueueDisplayError(error.toString()),
        );
      } catch (e) {
        emit(QueueDisplayError(e.toString()));
      }
    });
  }

  void _handleTicketUpdates(List<Ticket> currentTickets) {
    if (_previousTickets.isEmpty) {
      // Первая загрузка - не озвучиваем
      return;
    }

    // Находим новые вызванные талоны
    final currentCalled = currentTickets
        .where((ticket) => ticket.status == 'called')
        .toList();
    
    final previousCalled = _previousTickets
        .where((ticket) => ticket.status == 'called')
        .toList();

    for (final ticket in currentCalled) {
      // Проверяем, не был ли этот талон уже вызван ранее
      final wasAlreadyCalled = previousCalled.any((prev) => 
          prev.id == ticket.id && prev.status == 'called');
      
      if (!wasAlreadyCalled && ticket.window != null) {
        // Новый вызов - озвучиваем
        print('QueueDisplayBloc: New ticket called: ${ticket.id} -> window ${ticket.window}');
        _audioService.announceTicket(ticket.id, ticket.window!);
      }
    }

    // Очищаем информацию о последнем вызванном талоне если он больше не в списке вызванных
    final currentCalledIds = currentCalled.map((t) => t.id).toSet();
    final previousCalledIds = previousCalled.map((t) => t.id).toSet();
    
    // Если какой-то талон исчез из списка вызванных, очищаем кэш
    if (previousCalledIds.any((id) => !currentCalledIds.contains(id))) {
      _audioService.clearLastCalledTicket();
    }
  }

  @override
  Future<void> close() {
    _audioService.dispose();
    return super.close();
  }
}