import 'package:equatable/equatable.dart';
import '../../core/utils/ticket_category.dart';

class TicketEntity extends Equatable {
  final String id;
  final String number;
  final TicketCategory category;
  final String status;
  final bool isRegistered;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? calledAt;
  final DateTime? completedAt;

  const TicketEntity({
    required this.id,
    required this.number,
    required this.category,
    required this.status,
    this.isRegistered = false,
    this.isCompleted = false,
    required this.createdAt,
    this.calledAt,
    this.completedAt,
  });

  TicketEntity copyWith({
    String? id,
    String? number,
    TicketCategory? category,
    String? status,
    bool? isRegistered,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? calledAt,
    DateTime? completedAt,
  }) {
    return TicketEntity(
      id: id ?? this.id,
      number: number ?? this.number,
      category: category ?? this.category,
      status: status ?? this.status,
      isRegistered: isRegistered ?? this.isRegistered,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      calledAt: calledAt ?? this.calledAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    number,
    category,
    status,
    isRegistered,
    isCompleted,
    createdAt,
    calledAt,
    completedAt,
  ];
}