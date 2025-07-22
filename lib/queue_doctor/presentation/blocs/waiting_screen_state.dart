import 'package:equatable/equatable.dart';
import '../../domain/entities/waiting_screen_entity.dart';

abstract class WaitingScreenState extends Equatable {
  const WaitingScreenState();

  @override
  List<Object> get props => [];
}

class WaitingScreenInitial extends WaitingScreenState {}

class WaitingScreenLoading extends WaitingScreenState {}

// Состояние для выбора кабинета
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

// Состояние, когда данные об очереди загружены
class DoctorQueueLoaded extends WaitingScreenState {
  final DoctorQueueEntity queueEntity;

  const DoctorQueueLoaded({required this.queueEntity});

  @override
  List<Object> get props => [queueEntity];
}


// Состояние ошибки
class WaitingScreenError extends WaitingScreenState {
  final String message;

  const WaitingScreenError({required this.message});

  @override
  List<Object> get props => [message];
}