class Ticket {
  final String id;       // Номер талона, например: A001, B002
  final String status;   // "waiting" или "called"
  final String? window;  // Номер окна (если вызван)

  Ticket({
    required this.id,
    this.status = 'waiting',
    this.window,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    String mapStatus(String backendStatus) {
      switch (backendStatus) {
        case 'приглашен':
          return 'called';
        case 'ожидает':
          return 'waiting';
        default:
          return ''; 
      }
    }

    return Ticket(
      id: json['ticket_number'] as String,
      status: mapStatus(json['status'] as String),
      window: (json['window_number'] as int?)?.toString(),
    );
  }
}