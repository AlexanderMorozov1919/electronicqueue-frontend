class QueueEntity {
  final bool isAppointmentInProgress;
  final int queueLength;
  final String? currentTicket;

  const QueueEntity({
    required this.isAppointmentInProgress,
    required this.queueLength,
    this.currentTicket,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is QueueEntity &&
        other.isAppointmentInProgress == isAppointmentInProgress &&
        other.queueLength == queueLength &&
        other.currentTicket == currentTicket;
  }

  @override
  int get hashCode =>
      isAppointmentInProgress.hashCode ^
      queueLength.hashCode ^
      currentTicket.hashCode;
}