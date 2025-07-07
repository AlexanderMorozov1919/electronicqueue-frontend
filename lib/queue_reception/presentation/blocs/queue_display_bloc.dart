import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../presentation/blocs/queue_display_event.dart';
import '../blocs/queue_display_state.dart';


class QueueDisplayBloc extends Bloc<QueueDisplayEvent, QueueDisplayState> {
  final QueueRepository repository;
  
  QueueDisplayBloc(this.repository) : super(const QueueDisplayInitial()) {
    on<LoadTicketsEvent>((event, emit) async {
      try {
        emit(QueueDisplayLoading());
        final tickets = await repository.getActiveTickets().first;
        emit(QueueDisplayLoaded(tickets));
      } catch (e) {
        emit(QueueDisplayError(e.toString()));
      }
    });
  }
}