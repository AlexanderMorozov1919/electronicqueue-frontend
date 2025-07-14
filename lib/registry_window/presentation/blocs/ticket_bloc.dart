import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/usecases/call_next_ticket.dart';
import '../../domain/usecases/complete_current_ticket.dart';
import '../../domain/usecases/get_current_ticket.dart';
import '../../domain/usecases/get_tickets_by_category.dart';
import '../../domain/usecases/register_current_ticket.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final CallNextTicket callNextTicket;
  final RegisterCurrentTicket registerCurrentTicket;
  final CompleteCurrentTicket completeCurrentTicket;
  final GetCurrentTicket getCurrentTicket;
  final GetTicketsByCategory getTicketsByCategory;

  TicketBloc({
    required this.callNextTicket,
    required this.registerCurrentTicket,
    required this.completeCurrentTicket,
    required this.getCurrentTicket,
    required this.getTicketsByCategory,
  }) : super(TicketInitial()) {
    on<CallNextTicketEvent>(_onCallNextTicket);
    on<RegisterCurrentTicketEvent>(_onRegisterCurrentTicket);
    on<CompleteCurrentTicketEvent>(_onCompleteCurrentTicket);
    on<LoadCurrentTicketEvent>(_onLoadCurrentTicket);
    on<LoadTicketsByCategoryEvent>(_onLoadTicketsByCategory);
  }

  Future<void> _onCallNextTicket(
    CallNextTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final ticket = await callNextTicket();
      emit(TicketLoaded(
        currentTicket: ticket,
        ticketsByCategory: state.ticketsByCategory,
      ));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onRegisterCurrentTicket(
    RegisterCurrentTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final ticket = await registerCurrentTicket();
      emit(TicketLoaded(
        currentTicket: ticket,
        ticketsByCategory: state.ticketsByCategory,
      ));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onCompleteCurrentTicket(
    CompleteCurrentTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final ticket = await completeCurrentTicket();
      emit(TicketLoaded(
        currentTicket: ticket,
        ticketsByCategory: state.ticketsByCategory,
      ));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentTicket(
    LoadCurrentTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final ticket = await getCurrentTicket();
      emit(TicketLoaded(
        currentTicket: ticket,
        ticketsByCategory: state.ticketsByCategory,
      ));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onLoadTicketsByCategory(
    LoadTicketsByCategoryEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final tickets = await getTicketsByCategory(event.category);
      emit(TicketLoaded(
        currentTicket: state.currentTicket,
        ticketsByCategory: {
          ...state.ticketsByCategory,
          event.category: tickets,
        },
      ));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }
}