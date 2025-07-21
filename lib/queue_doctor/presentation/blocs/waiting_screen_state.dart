import 'package:equatable/equatable.dart';

abstract class WaitingScreenState extends Equatable {
  const WaitingScreenState();

  @override
  List<Object> get props => [];
}

class WaitingScreenInitial extends WaitingScreenState {}

class WaitingScreenLoading extends WaitingScreenState {}

class CabinetSelection extends WaitingScreenState {
  final List<int> allCabinets;
  final List<int> filteredCabinets;

  const CabinetSelection({
    required this.allCabinets,
    required this.filteredCabinets,
  });

  @override
  List<Object> get props => [allCabinets, filteredCabinets];

  CabinetSelection copyWith({
    List<int>? allCabinets,
    List<int>? filteredCabinets,
  }) {
    return CabinetSelection(
      allCabinets: allCabinets ?? this.allCabinets,
      filteredCabinets: filteredCabinets ?? this.filteredCabinets,
    );
  }
}

// Новое состояние для отображения сообщения "Нет приема"
class WaitingScreenNoReception extends WaitingScreenState {
  final String message;

  const WaitingScreenNoReception({required this.message});

  @override
  List<Object> get props => [message];
}

class WaitingScreenWaiting extends WaitingScreenState {
  final String doctorName;
  final String doctorSpecialty;
  final int cabinetNumber;

  const WaitingScreenWaiting({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.cabinetNumber,
  });

  @override
  List<Object> get props => [doctorName, doctorSpecialty, cabinetNumber];
}

class WaitingScreenCalled extends WaitingScreenState {
  final String doctorName;
  final String doctorSpecialty;
  final int cabinetNumber;
  final String ticketNumber;

  const WaitingScreenCalled({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.cabinetNumber,
    required this.ticketNumber,
  });

  @override
  List<Object> get props =>
      [doctorName, doctorSpecialty, cabinetNumber, ticketNumber];
}

class WaitingScreenError extends WaitingScreenState {
  final String message;

  const WaitingScreenError({required this.message});

  @override
  List<Object> get props => [message];
}