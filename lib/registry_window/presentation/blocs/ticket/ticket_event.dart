import 'package:equatable/equatable.dart';
import '../../../core/utils/ticket_category.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object> get props => [];
}

class CallNextTicketEvent extends TicketEvent {}

class RegisterCurrentTicketEvent extends TicketEvent {}

class CompleteCurrentTicketEvent extends TicketEvent {}

class LoadCurrentTicketEvent extends TicketEvent {}

class LoadTicketsByCategoryEvent extends TicketEvent {
  final TicketCategory category;

  const LoadTicketsByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class ClearInfoMessageEvent extends TicketEvent {}