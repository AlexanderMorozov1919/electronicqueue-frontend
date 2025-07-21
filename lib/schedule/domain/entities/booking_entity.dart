class BookingEntity {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final int status;

  BookingEntity({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}
