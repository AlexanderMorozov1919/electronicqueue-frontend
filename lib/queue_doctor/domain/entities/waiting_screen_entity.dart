import 'package:equatable/equatable.dart';

class WaitingScreenEntity extends Equatable {
  final String doctorName;
  final String doctorSpecialty;
  final int officeNumber;
  final String? currentTicket;
  final bool isCalled;

  const WaitingScreenEntity({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.officeNumber,
    this.currentTicket,
    required this.isCalled,
  });

  @override
  List<Object?> get props => [doctorName, doctorSpecialty, officeNumber, currentTicket, isCalled];
}