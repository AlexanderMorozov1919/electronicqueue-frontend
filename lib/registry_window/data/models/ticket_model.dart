import 'package:equatable/equatable.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../core/utils/ticket_category.dart';

class TicketModel extends Equatable {
  final String id;
  final String number;
  final TicketCategory category;
  final bool isRegistered;
  final bool isCompleted;
  final DateTime createdAt;

  const TicketModel({
    required this.id,
    required this.number,
    required this.category,
    this.isRegistered = false,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory TicketModel.fromEntity(TicketEntity entity) {
    return TicketModel(
      id: entity.id,
      number: entity.number,
      category: entity.category,
      isRegistered: entity.isRegistered,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
    );
  }

  TicketEntity toEntity() {
    return TicketEntity(
      id: id,
      number: number,
      category: category,
      isRegistered: isRegistered,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }

  TicketModel copyWith({
    String? id,
    String? number,
    TicketCategory? category,
    bool? isRegistered,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      number: number ?? this.number,
      category: category ?? this.category,
      isRegistered: isRegistered ?? this.isRegistered,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, number, category, isRegistered, isCompleted, createdAt];
}