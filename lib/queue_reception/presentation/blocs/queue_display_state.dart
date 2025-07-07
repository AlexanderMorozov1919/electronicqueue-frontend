import '../../domain/entities/ticket.dart';


sealed class QueueDisplayState {
  const QueueDisplayState();
}

class QueueDisplayInitial extends QueueDisplayState {
  const QueueDisplayInitial();
}

class QueueDisplayLoading extends QueueDisplayState {}

class QueueDisplayLoaded extends QueueDisplayState {
  final List<Ticket> tickets;
  
  const QueueDisplayLoaded(this.tickets);
}

class QueueDisplayError extends QueueDisplayState {
  final String message;
  
  const QueueDisplayError(this.message);
}