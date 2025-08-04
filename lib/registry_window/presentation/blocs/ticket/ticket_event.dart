import 'package:equatable/equatable.dart';
import '../../../core/utils/ticket_category.dart';
import '../../../domain/entities/ticket_entity.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class CallNextTicketEvent extends TicketEvent {
  final int windowNumber;
  final TicketCategory? category;

  const CallNextTicketEvent({required this.windowNumber, this.category});

  @override
  List<Object?> get props => [windowNumber, category];
}

class RegisterCurrentTicketEvent extends TicketEvent {}

class CompleteCurrentTicketEvent extends TicketEvent {}

class LoadCurrentTicketEvent extends TicketEvent {}

class LoadTicketsByCategoryEvent extends TicketEvent {
  final TicketCategory category;

  const LoadTicketsByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class SelectTicketEvent extends TicketEvent {
  final TicketEntity ticket;

  const SelectTicketEvent(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class CallSpecificTicketEvent extends TicketEvent {
  final int windowNumber;

  const CallSpecificTicketEvent(this.windowNumber);

  @override
  List<Object> get props => [windowNumber];
}

class ClearInfoMessageEvent extends TicketEvent {}