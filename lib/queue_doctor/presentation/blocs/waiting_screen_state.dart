import 'package:equatable/equatable.dart';

abstract class WaitingScreenState extends Equatable {
  const WaitingScreenState();

  @override
  List<Object> get props => [];
}

class WaitingScreenInitial extends WaitingScreenState {}

class WaitingScreenLoading extends WaitingScreenState {}

class WaitingScreenWaiting extends WaitingScreenState {
  final String doctorName;
  final String doctorSpecialty;
  final int officeNumber;

  const WaitingScreenWaiting({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.officeNumber,
  });

  @override
  List<Object> get props => [doctorName, doctorSpecialty, officeNumber];
}

class WaitingScreenCalled extends WaitingScreenState {
  final String doctorName;
  final String doctorSpecialty;
  final int officeNumber;
  final String ticketNumber;

  const WaitingScreenCalled({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.officeNumber,
    required this.ticketNumber,
  });

  @override
  List<Object> get props => [doctorName, doctorSpecialty, officeNumber, ticketNumber];
}

class WaitingScreenError extends WaitingScreenState {
  final String message;

  const WaitingScreenError({required this.message});

  @override
  List<Object> get props => [message];
}