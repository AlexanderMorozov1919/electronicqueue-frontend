class WaitingScreenEntity {
  final String doctorName;
  final String doctorSpecialty;
  final int officeNumber;
  final String? currentTicket;
  final bool isCalled;

  WaitingScreenEntity({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.officeNumber,
    this.currentTicket,
    this.isCalled = false,
  });
}