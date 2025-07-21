import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../core/utils/ticket_category.dart';
import '../../../domain/usecases/call_next_ticket.dart';
import '../../../domain/usecases/complete_current_ticket.dart';
import '../../../domain/usecases/get_current_ticket.dart';
import '../../../domain/usecases/get_tickets_by_category.dart';
import '../../../domain/usecases/register_current_ticket.dart';
import '../../../domain/entities/ticket_entity.dart';
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
    on<ClearInfoMessageEvent>(_onClearInfoMessage);
  }

  Future<void> _onCallNextTicket(
    CallNextTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading(
      currentTicket: state.currentTicket,
      ticketsByCategory: state.ticketsByCategory,
      selectedCategory: state.selectedCategory,
    ));
    
    final result = await callNextTicket();
    
    result.fold(
      (failure) {
        if (failure.message.contains('Очередь пуста')) {
          emit(TicketLoaded(
            currentTicket: state.currentTicket,
            ticketsByCategory: state.ticketsByCategory,
            selectedCategory: state.selectedCategory,
            infoMessage: 'Очередь пуста',
          ));
        } else {
          emit(TicketError(
            message: failure.message,
            currentTicket: state.currentTicket,
            ticketsByCategory: state.ticketsByCategory,
            selectedCategory: state.selectedCategory,
          ));
        }
      },
      (ticket) => emit(TicketLoaded(currentTicket: ticket)),
    );
  }

  void _onClearInfoMessage(
    ClearInfoMessageEvent event,
    Emitter<TicketState> emit,
  ) {
    if (state is TicketLoaded) {
      emit((state as TicketLoaded).copyWith(infoMessage: null));
    }
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
          final newMap = Map<TicketCategory, List<TicketEntity>>.from(state.ticketsByCategory);
          final categoryList = newMap[updatedTicket.category];

          if (categoryList != null) {
            final ticketIndex = categoryList.indexWhere((t) => t.id == updatedTicket.id);
            if (ticketIndex != -1) {
              categoryList[ticketIndex] = updatedTicket;
            }
          }

          emit(TicketLoaded(
            currentTicket: updatedTicket,
            ticketsByCategory: newMap, 
            selectedCategory: state.selectedCategory,
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
          final newMap = Map<TicketCategory, List<TicketEntity>>.from(state.ticketsByCategory);
          final categoryList = newMap[updatedTicket.category];

          if (categoryList != null) {
            final ticketIndex = categoryList.indexWhere((t) => t.id == updatedTicket.id);
            if (ticketIndex != -1) {
              categoryList[ticketIndex] = updatedTicket;
            }
          }

          emit(TicketLoaded(
            currentTicket: updatedTicket,
            ticketsByCategory: newMap, 
            selectedCategory: state.selectedCategory,
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
      selectedCategory: event.category,
    ));
    
    final result = await getTicketsByCategory(event.category);
    result.fold(
      (failure) {
        emit(TicketError(
          message: failure.message,
          currentTicket: state.currentTicket,
          ticketsByCategory: state.ticketsByCategory,
          selectedCategory: state.selectedCategory,
        ));
      },
      (tickets) {
        final newMap = Map<TicketCategory, List<TicketEntity>>.from(state.ticketsByCategory);
        newMap[event.category] = tickets;
        
        emit(TicketLoaded(
          currentTicket: state.currentTicket,
          ticketsByCategory: newMap,
          selectedCategory: event.category,
        ));
      },
    );
  }
}