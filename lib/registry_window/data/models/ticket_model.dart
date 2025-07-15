import '../../domain/entities/ticket_entity.dart';
import '../../core/utils/ticket_category.dart';

class TicketModel extends TicketEntity {
  const TicketModel({
    required super.id,
    required super.number,
    required super.category,
    required super.createdAt,
    super.isRegistered,
    super.isCompleted,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    TicketCategory determineCategory(String ticketNumber) {
      if (ticketNumber.startsWith('A')) return TicketCategory.byAppointment;
      if (ticketNumber.startsWith('B')) return TicketCategory.makeAppointment;
      if (ticketNumber.startsWith('C')) return TicketCategory.tests;
      return TicketCategory.other;
    }

    final ticketNumber = json['ticket_number'] as String;
    final status = json['status'] as String?;

    return TicketModel(
      id: json['id'].toString(),
      number: ticketNumber,
      category: determineCategory(ticketNumber),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRegistered: status == 'зарегистрирован',
      isCompleted: status == 'завершен',
    );
  }

  Map<String, dynamic> toJson() {
    String status = 'ожидает';
    if (isCompleted) {
      status = 'завершен';
    } else if (isRegistered) {
      status = 'зарегистрирован';
    }

    return {
      'id': id,
      'ticket_number': number,
      'category': category.name,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}