import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../core/utils/ticket_category.dart';
import '../../../domain/usecases/call_next_ticket.dart';
import '../../../domain/usecases/call_specific_ticket.dart';
import '../../../domain/usecases/complete_current_ticket.dart';
import '../../../domain/usecases/get_current_ticket.dart';
import '../../../domain/usecases/get_process_status.dart';
import '../../../domain/usecases/get_tickets_by_category.dart';
import '../../../domain/usecases/register_current_ticket.dart';
import '../../../domain/entities/ticket_entity.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final CallNextTicket callNextTicket;
  final CallSpecificTicket callSpecificTicket;
  final RegisterCurrentTicket registerCurrentTicket;
  final CompleteCurrentTicket completeCurrentTicket;
  final GetCurrentTicket getCurrentTicket;
  final GetTicketsByCategory getTicketsByCategory;
  final GetProcessStatus getProcessStatus;

  TicketBloc({
    required this.callNextTicket,
    required this.callSpecificTicket,
    required this.registerCurrentTicket,
    required this.completeCurrentTicket,
    required this.getCurrentTicket,
    required this.getTicketsByCategory,
    required this.getProcessStatus,
  }) : super(TicketInitial()) {
    on<CallNextTicketEvent>(_onCallNextTicket);
    on<CallSpecificTicketEvent>(_onCallSpecificTicket);
    on<SelectTicketEvent>(_onSelectTicket);
    on<RegisterCurrentTicketEvent>(_onRegisterCurrentTicket);
    on<CompleteCurrentTicketEvent>(_onCompleteCurrentTicket);
    on<LoadCurrentTicketEvent>(_onLoadCurrentTicket);
    on<LoadTicketsByCategoryEvent>(_onLoadTicketsByCategory);
    on<ClearInfoMessageEvent>(_onClearInfoMessage);
    on<CheckAppointmentButtonStatus>(_onCheckAppointmentButtonStatus);
  }

  Future<void> _onCheckAppointmentButtonStatus(
    CheckAppointmentButtonStatus event,
    Emitter<TicketState> emit,
  ) async {
    final result = await getProcessStatus('appointment');
    final currentState = state; // Захватываем текущее состояние

    result.fold(
      (failure) {
        // В случае ошибки, по умолчанию кнопка включена, сохраняем остальное состояние
        if (currentState is TicketLoaded) {
          emit(currentState.copyWith(isAppointmentButtonEnabled: true));
        } else {
          emit(TicketLoaded(
            currentTicket: currentState.currentTicket,
            ticketsByCategory: currentState.ticketsByCategory,
            selectedCategory: currentState.selectedCategory,
            selectedTicket: currentState.selectedTicket,
            isAppointmentButtonEnabled: true,
          ));
        }
      },
      (isEnabled) {
        // При успехе, обновляем состояние кнопки, сохраняя все остальное
        if (currentState is TicketLoaded) {
          emit(currentState.copyWith(isAppointmentButtonEnabled: isEnabled));
        } else {
          emit(TicketLoaded(
            currentTicket: currentState.currentTicket,
            ticketsByCategory: currentState.ticketsByCategory,
            selectedCategory: currentState.selectedCategory,
            selectedTicket: currentState.selectedTicket,
            isAppointmentButtonEnabled: isEnabled,
          ));
        }
      },
    );
  }

  Future<void> _onCallNextTicket(
    CallNextTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading(
      currentTicket: state.currentTicket,
      ticketsByCategory: state.ticketsByCategory,
      selectedCategory: state.selectedCategory,
      isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
    ));

    String? categoryPrefix;
    if (event.category != null && event.category != TicketCategory.all) {
      switch (event.category) {
        case TicketCategory.makeAppointment:
          categoryPrefix = 'A';
          break;
        case TicketCategory.byAppointment:
          categoryPrefix = 'B';
          break;
        case TicketCategory.tests:
          categoryPrefix = 'C';
          break;
        case TicketCategory.other:
          categoryPrefix = 'D';
          break;
        default:
          categoryPrefix = null;
      }
    }

    final result = await callNextTicket(
      windowNumber: event.windowNumber,
      categoryPrefix: categoryPrefix,
    );

    result.fold(
      (failure) {
        if (failure.message.contains('Очередь пуста')) {
          emit(TicketLoaded(
            currentTicket: state.currentTicket,
            ticketsByCategory: state.ticketsByCategory,
            selectedCategory: state.selectedCategory,
            infoMessage: 'Очередь пуста',
            isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
          ));
        } else {
          emit(TicketError(
            message: failure.message,
            currentTicket: state.currentTicket,
            ticketsByCategory: state.ticketsByCategory,
            selectedCategory: state.selectedCategory,
            isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
          ));
        }
      },
      (ticket) {
        emit(TicketLoaded(currentTicket: ticket, isAppointmentButtonEnabled: state.isAppointmentButtonEnabled));
        if (state.selectedCategory != null) {
          add(LoadTicketsByCategoryEvent(state.selectedCategory!));
        }
        add(CheckAppointmentButtonStatus());
      },
    );
  }

  void _onSelectTicket(
    SelectTicketEvent event,
    Emitter<TicketState> emit,
  ) {
    if (state is TicketLoaded) {
      final loadedState = state as TicketLoaded;
      final currentlySelected = loadedState.selectedTicket;

      if (currentlySelected?.id == event.ticket.id) {
        emit(loadedState.copyWith(clearSelectedTicket: true));
      } else {
        emit(loadedState.copyWith(selectedTicket: event.ticket));
      }
    }
  }

  Future<void> _onCallSpecificTicket(
    CallSpecificTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    if (state.selectedTicket == null) return;
    final ticketToCall = state.selectedTicket!;

    emit(TicketLoading(
      currentTicket: state.currentTicket,
      ticketsByCategory: state.ticketsByCategory,
      selectedCategory: state.selectedCategory,
      selectedTicket: state.selectedTicket,
      isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
    ));

    final result =
        await callSpecificTicket(ticketToCall.id, event.windowNumber);

    result.fold(
      (failure) => emit(TicketError(
        message: failure.message,
        currentTicket: state.currentTicket,
        ticketsByCategory: state.ticketsByCategory,
        selectedCategory: state.selectedCategory,
        selectedTicket: state.selectedTicket,
        isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
      )),
      (calledTicket) {
        emit(TicketLoaded(
          currentTicket: calledTicket,
          selectedTicket: null,
          ticketsByCategory: state.ticketsByCategory,
          selectedCategory: state.selectedCategory,
          isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
        ));
        if (state.selectedCategory != null) {
          add(LoadTicketsByCategoryEvent(state.selectedCategory!));
        }
        add(CheckAppointmentButtonStatus());
      },
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
      emit(TicketLoading(currentTicket: ticketToUpdate, isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,));

      final result = await registerCurrentTicket(ticketToUpdate.id);

      result.fold(
        (failure) => emit(
            TicketError(message: failure.message, currentTicket: ticketToUpdate, isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,)),
        (_) {
          final updatedTicket = ticketToUpdate.copyWith(isRegistered: true);
          final newMap =
              Map<TicketCategory, List<TicketEntity>>.from(state.ticketsByCategory);
          final categoryList = newMap[updatedTicket.category];

          if (categoryList != null) {
            final ticketIndex =
                categoryList.indexWhere((t) => t.id == updatedTicket.id);
            if (ticketIndex != -1) {
              categoryList[ticketIndex] = updatedTicket;
            }
          }

          emit(TicketLoaded(
            currentTicket: updatedTicket,
            ticketsByCategory: newMap,
            selectedCategory: state.selectedCategory,
            isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
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
      emit(TicketLoading(currentTicket: ticketToUpdate, isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,));

      final result = await completeCurrentTicket(ticketToUpdate.id);

      result.fold(
        (failure) => emit(
            TicketError(message: failure.message, currentTicket: ticketToUpdate, isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,)),
        (_) {
          final updatedTicket = ticketToUpdate.copyWith(isCompleted: true);
          final newMap =
              Map<TicketCategory, List<TicketEntity>>.from(state.ticketsByCategory);
          final categoryList = newMap[updatedTicket.category];

          if (categoryList != null) {
            final ticketIndex =
                categoryList.indexWhere((t) => t.id == updatedTicket.id);
            if (ticketIndex != -1) {
              categoryList[ticketIndex] = updatedTicket;
            }
          }

          emit(TicketLoaded(
            currentTicket: updatedTicket,
            ticketsByCategory: newMap,
            selectedCategory: state.selectedCategory,
            isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
          ));
        },
      );
    }
  }

  Future<void> _onLoadCurrentTicket(
    LoadCurrentTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading(isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,));
    emit(TicketLoaded(currentTicket: null, isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,));
  }

  Future<void> _onLoadTicketsByCategory(
    LoadTicketsByCategoryEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading(
      currentTicket: state.currentTicket,
      ticketsByCategory: state.ticketsByCategory,
      selectedCategory: event.category,
      selectedTicket: state.selectedTicket,
      isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
    ));

    final result = await getTicketsByCategory(event.category);
    result.fold(
      (failure) {
        emit(TicketError(
          message: failure.message,
          currentTicket: state.currentTicket,
          ticketsByCategory: state.ticketsByCategory,
          selectedCategory: state.selectedCategory,
          isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
        ));
      },
      (tickets) {
        final newMap =
            Map<TicketCategory, List<TicketEntity>>.from(state.ticketsByCategory);
        newMap[event.category] = tickets;

        emit(TicketLoaded(
          currentTicket: state.currentTicket,
          ticketsByCategory: newMap,
          selectedCategory: event.category,
          selectedTicket: state.selectedTicket,
          isAppointmentButtonEnabled: state.isAppointmentButtonEnabled,
        ));
      },
    );
  }
}