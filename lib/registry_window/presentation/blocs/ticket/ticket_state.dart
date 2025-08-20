import 'package:equatable/equatable.dart';
import '../../../domain/entities/service_entity.dart';
import '../../../domain/entities/ticket_entity.dart';
import '../../../core/utils/ticket_category.dart';

abstract class TicketState extends Equatable {
  final TicketEntity? currentTicket;
  final Map<TicketCategory, List<TicketEntity>> ticketsByCategory;
  final TicketCategory? selectedCategory;
  final String? infoMessage;
  final TicketEntity? selectedTicket;
  final bool isAppointmentButtonEnabled;
  final List<ServiceEntity> availableCategories;

  const TicketState({
    this.currentTicket,
    this.ticketsByCategory = const {},
    this.selectedCategory,
    this.infoMessage,
    this.selectedTicket,
    this.isAppointmentButtonEnabled = true,
    this.availableCategories = const [],
  });

  @override
  List<Object?> get props => [
        currentTicket,
        ticketsByCategory,
        selectedCategory,
        infoMessage,
        selectedTicket,
        isAppointmentButtonEnabled,
        availableCategories,
      ];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {
  const TicketLoading({
    super.currentTicket,
    super.ticketsByCategory,
    super.selectedCategory,
    super.infoMessage,
    super.selectedTicket,
    super.isAppointmentButtonEnabled,
    super.availableCategories,
  });
}

class TicketLoaded extends TicketState {
  const TicketLoaded({
    super.currentTicket,
    super.ticketsByCategory = const {},
    super.selectedCategory,
    super.infoMessage,
    super.selectedTicket,
    super.isAppointmentButtonEnabled = true,
    super.availableCategories = const [],
  });

  TicketLoaded copyWith({
    TicketEntity? currentTicket,
    Map<TicketCategory, List<TicketEntity>>? ticketsByCategory,
    TicketCategory? selectedCategory,
    String? infoMessage,
    TicketEntity? selectedTicket,
    bool? isAppointmentButtonEnabled,
    List<ServiceEntity>? availableCategories,
    bool clearSelectedTicket = false,
  }) {
    return TicketLoaded(
      currentTicket: currentTicket ?? this.currentTicket,
      ticketsByCategory: ticketsByCategory ?? this.ticketsByCategory,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      infoMessage: infoMessage,
      selectedTicket:
          clearSelectedTicket ? null : selectedTicket ?? this.selectedTicket,
      isAppointmentButtonEnabled: isAppointmentButtonEnabled ?? this.isAppointmentButtonEnabled,
      availableCategories: availableCategories ?? this.availableCategories,
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
    super.selectedTicket,
    super.isAppointmentButtonEnabled = true,
    super.availableCategories = const [],
  });

  @override
  List<Object?> get props => [
        message,
        currentTicket,
        ticketsByCategory,
        selectedCategory,
        infoMessage,
        selectedTicket,
        isAppointmentButtonEnabled,
        availableCategories,
      ];
}