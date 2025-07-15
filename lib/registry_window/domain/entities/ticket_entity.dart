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

  TicketEntity copyWith({
    String? id,
    String? number,
    TicketCategory? category,
    bool? isRegistered,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TicketEntity(
      id: id ?? this.id,
      number: number ?? this.number,
      category: category ?? this.category,
      isRegistered: isRegistered ?? this.isRegistered,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    number,
    category,
    isRegistered,
    isCompleted,
    createdAt,
  ];
}
