import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../presentation/blocs/queue_display_event.dart';
import '../blocs/queue_display_state.dart';
import '../../domain/entities/ticket.dart';

class QueueDisplayBloc extends Bloc<QueueDisplayEvent, QueueDisplayState> {
  final QueueRepository repository;

  QueueDisplayBloc(this.repository) : super(const QueueDisplayInitial()) {
    on<LoadTicketsEvent>((event, emit) async {
      emit(QueueDisplayLoading());
      try {
        final ticketStream = repository.getActiveTickets();

        await emit.forEach<List<Ticket>>(
          ticketStream,
          onData: (tickets) => QueueDisplayLoaded(tickets),
          onError: (error, stackTrace) => QueueDisplayError(error.toString()),
        );
      } catch (e) {
        emit(QueueDisplayError(e.toString()));
      }
    });
  }
}
