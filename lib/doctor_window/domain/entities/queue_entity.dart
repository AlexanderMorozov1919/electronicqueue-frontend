class QueueEntity {
  final bool isAppointmentInProgress;
  final int queueLength;
  final String? currentTicket;
  final int? activeTicketId;

  const QueueEntity({
    required this.isAppointmentInProgress,
    required this.queueLength,
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