import '../../domain/entities/ticket_entity.dart';
import '../../core/utils/ticket_category.dart';

class TicketModel extends TicketEntity {
  const TicketModel({
    required super.id,
    required super.number,
    required super.category,
    required super.createdAt,
    required super.status,
    super.isRegistered,
    super.isCompleted,
    super.calledAt,
    super.completedAt,
    super.appointmentTime,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    TicketCategory determineCategory(String ticketNumber) {
      if (ticketNumber.startsWith('A')) return TicketCategory.makeAppointment;
      if (ticketNumber.startsWith('B')) return TicketCategory.byAppointment;
      if (ticketNumber.startsWith('C')) return TicketCategory.tests;
      if (ticketNumber.startsWith('D')) return TicketCategory.other;
      return TicketCategory.other;
    }

    final ticketNumber = json['ticket_number'] as String;
    final status = json['status'] as String? ?? 'ожидает';
    final idValue = json['id'] ?? json['ticket_id'];

    return TicketModel(
      id: idValue.toString(),
      number: ticketNumber,
      category: determineCategory(ticketNumber),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      calledAt: json['called_at'] != null
          ? DateTime.parse(json['called_at'] as String).toLocal()
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String).toLocal()
          : null,
      appointmentTime: json['appointment_time'] != null
          ? DateTime.parse(json['appointment_time'] as String) // Убрано .toLocal()
          : null,
      status: status,
      isRegistered: status == 'зарегистрирован',
      isCompleted: status == 'завершен',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': number,
      'category': category.name,
      'created_at': createdAt.toIso8601String(),
      'called_at': calledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'appointment_time': appointmentTime?.toIso8601String(),
      'status': status,
    };
  }
}