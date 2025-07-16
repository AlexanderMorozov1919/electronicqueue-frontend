import 'package:equatable/equatable.dart';
import '../../../domain/entities/ticket_entity.dart';
import '../../../core/utils/ticket_category.dart';

abstract class TicketState extends Equatable {
  final TicketEntity? currentTicket;
  final Map<TicketCategory, List<TicketEntity>> ticketsByCategory;
  final TicketCategory? selectedCategory;
  final String? infoMessage; 

  const TicketState({
    this.currentTicket,
    this.ticketsByCategory = const {},
    this.selectedCategory,
    this.infoMessage, 
  });

  @override
  List<Object?> get props => [currentTicket, ticketsByCategory, selectedCategory, infoMessage]; 
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {
  const TicketLoading({
    super.currentTicket,
    super.ticketsByCategory,
    super.selectedCategory,
    super.infoMessage, 
  });
}

class TicketLoaded extends TicketState {
  const TicketLoaded({
    super.currentTicket,
    super.ticketsByCategory = const {},
    super.selectedCategory,
    super.infoMessage,
  });

  TicketLoaded copyWith({
    TicketEntity? currentTicket,
    Map<TicketCategory, List<TicketEntity>>? ticketsByCategory,
    TicketCategory? selectedCategory,
    String? infoMessage,
  }) {
    return TicketLoaded(
      currentTicket: currentTicket ?? this.currentTicket,
      ticketsByCategory: ticketsByCategory ?? this.ticketsByCategory,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      infoMessage: infoMessage,
    );
  }
}

class TicketError extends TicketState {
  final String message;
  const TicketError({
    required this.message,
    super.currentTicket,
    super.ticketsByCategory = const {},
    super.selectedCategory,
    super.infoMessage, 
  });

  @override
  List<Object?> get props => [message, currentTicket, ticketsByCategory, selectedCategory, infoMessage]; 
}