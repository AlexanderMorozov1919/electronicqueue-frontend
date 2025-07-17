class QueueEntity {
  final bool isAppointmentInProgress;
  final int queueLength;
  final String? currentTicket;
  final int? activeTicketId;
  final bool isOnBreak;

  const QueueEntity({
    required this.isAppointmentInProgress,
    required this.queueLength,
    required this.isOnBreak,
    this.currentTicket,
    this.activeTicketId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is QueueEntity &&
        other.isAppointmentInProgress == isAppointmentInProgress &&
        other.queueLength == queueLength &&
        other.activeTicketId == activeTicketId &&
        other.currentTicket == currentTicket;
  }

  @override
  int get hashCode =>
      isAppointmentInProgress.hashCode ^
      queueLength.hashCode ^
      activeTicketId.hashCode ^
      currentTicket.hashCode;
}