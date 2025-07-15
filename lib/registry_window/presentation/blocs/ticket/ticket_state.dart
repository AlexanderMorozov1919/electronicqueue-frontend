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

class TicketLoading extends TicketState {}

class TicketLoaded extends TicketState {
  @override
  final TicketEntity? currentTicket;
  @override
  final Map<TicketCategory, List<TicketEntity>> ticketsByCategory;

  const TicketLoaded({
    this.currentTicket,
    this.ticketsByCategory = const {},
  }) : super(
          currentTicket: currentTicket,
          ticketsByCategory: ticketsByCategory,
        );

  @override
  List<Object?> get props => [currentTicket, ticketsByCategory];
}

class TicketError extends TicketState {
  final String message;

  const TicketError({required this.message});

  @override
  List<Object> get props => [message];
}