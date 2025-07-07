class Ticket {
  final String id;       // A001, B002 и т.д.
  final String status;   // "waiting" или "called"
  final String? window;  // Номер окна (если вызван)

  Ticket({
    required this.id,
    this.status = 'waiting',
    this.window,
  });
}