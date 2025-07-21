import 'package:equatable/equatable.dart';

class WaitingScreenEntity extends Equatable {
  final String doctorName;
  final String doctorSpecialty;
  final int cabinetNumber;
  final String? currentTicket;
  final bool isCalled;
  final String? message; // Сообщение от сервера, например, "нет приема"

  const WaitingScreenEntity({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.cabinetNumber,
    this.currentTicket,
    required this.isCalled,
    this.message,
  });

  @override
  List<Object?> get props => [
        doctorName,
        doctorSpecialty,
        cabinetNumber,
        currentTicket,
        isCalled,
        message
      ];
}