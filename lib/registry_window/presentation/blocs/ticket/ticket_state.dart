import 'package:equatable/equatable.dart';
import '../../../domain/entities/ticket_entity.dart';
import '../../../core/utils/ticket_category.dart';

abstract class TicketState extends Equatable {
  final TicketEntity? currentTicket;
  final Map<TicketCategory, List<TicketEntity>> ticketsByCategory;

  const TicketState({
    this.currentTicket,
    this.ticketsByCategory = const {},
  });

  @override
  List<Object?> get props => [currentTicket, ticketsByCategory];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {
   const TicketLoading({
      super.currentTicket, 
      super.ticketsByCategory
   });
}

class TicketLoaded extends TicketState {
  const TicketLoaded({
    super.currentTicket,
    super.ticketsByCategory = const {},
  });
}

class TicketError extends TicketState {
  final String message;
  const TicketError({
    required this.message, 
    super.currentTicket, 
    super.ticketsByCategory = const {},
  });

  @override
  List<Object?> get props => [message, currentTicket, ticketsByCategory];
}