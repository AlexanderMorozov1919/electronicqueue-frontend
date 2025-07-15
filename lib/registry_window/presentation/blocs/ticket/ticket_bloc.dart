import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../core/utils/ticket_category.dart';
import '../../../domain/usecases/call_next_ticket.dart';
import '../../../domain/usecases/complete_current_ticket.dart';
import '../../../domain/usecases/get_current_ticket.dart';
import '../../../domain/usecases/get_tickets_by_category.dart';
import '../../../domain/usecases/register_current_ticket.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';
import '../../../domain/entities/ticket_entity.dart';

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
    emit(TicketLoading(currentTicket: state.currentTicket));
    final result = await callNextTicket();
    result.fold(
      (failure) => emit(TicketError(message: failure.message, currentTicket: state.currentTicket)),
      (ticket) => emit(TicketLoaded(currentTicket: ticket)),
    );
  }

  Future<void> _onRegisterCurrentTicket(
    RegisterCurrentTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    final TicketEntity? ticketToUpdate = state.currentTicket;
    if (ticketToUpdate != null) {
      emit(TicketLoading(currentTicket: ticketToUpdate));
      
      final result = await registerCurrentTicket(ticketToUpdate.id);
      
      result.fold(
        (failure) => emit(TicketError(message: failure.message, currentTicket: ticketToUpdate)),
        (_) {
          final updatedTicket = ticketToUpdate.copyWith(isRegistered: true);
          emit(TicketLoaded(
            currentTicket: updatedTicket,
            ticketsByCategory: state.ticketsByCategory,
          ));
        },
      );
    }
  }

  Future<void> _onCompleteCurrentTicket(
    CompleteCurrentTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    final TicketEntity? ticketToUpdate = state.currentTicket;
    if (ticketToUpdate != null) {
      emit(TicketLoading(currentTicket: ticketToUpdate));

      final result = await completeCurrentTicket(ticketToUpdate.id);

      result.fold(
        (failure) => emit(TicketError(message: failure.message, currentTicket: ticketToUpdate)),
        (_) {
          final updatedTicket = ticketToUpdate.copyWith(isCompleted: true);
          emit(TicketLoaded(
            currentTicket: updatedTicket,
            ticketsByCategory: state.ticketsByCategory,
          ));
        },
      );
    }
  }

  Future<void> _onLoadCurrentTicket(
    LoadCurrentTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    emit(const TicketLoaded(currentTicket: null));
  }
  Future<void> _onLoadTicketsByCategory(
    LoadTicketsByCategoryEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading(
      currentTicket: state.currentTicket,
      ticketsByCategory: state.ticketsByCategory,
    ));
    
    final result = await getTicketsByCategory(event.category);
    result.fold(
      (failure) {
        emit(TicketError(
          message: failure.message,
          currentTicket: state.currentTicket,
          ticketsByCategory: state.ticketsByCategory,
        ));
      },
      (tickets) {
        final newMap = Map<TicketCategory, List<TicketEntity>>.from(state.ticketsByCategory);
        newMap[event.category] = tickets;
        
        emit(TicketLoaded(
          currentTicket: state.currentTicket,
          ticketsByCategory: newMap,
        ));
      },
    );
  }
}