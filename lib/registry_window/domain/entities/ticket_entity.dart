import 'package:equatable/equatable.dart';
import '../../core/utils/ticket_category.dart';

class TicketEntity extends Equatable {
  final String id;
  final String number;
  final TicketCategory category;
  final bool isRegistered;
  final bool isCompleted;
  final DateTime createdAt;

  const TicketEntity({
    required this.id,
    required this.number,
    required this.category,
    this.isRegistered = false,
    this.isCompleted = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, number, category, isRegistered, isCompleted, createdAt];
}