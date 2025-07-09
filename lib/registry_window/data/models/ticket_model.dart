import 'package:equatable/equatable.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../core/utils/ticket_category.dart';

// ВАЖНО: Мы сохраняем старые поля (isRegistered, isCompleted, category)
// чтобы не сломать остальную часть приложения, которая все еще работает с заглушками.
class TicketModel extends Equatable {
  final String id;
  final String number;
  final TicketCategory category; // Оставляем для старой логики
  final bool isRegistered; // Оставляем для старой логики
  final bool isCompleted; // Оставляем для старой логики
  final DateTime createdAt;
  final String? status; // Новое поле из API
  final int? windowNumber; // Новое поле из API

  const TicketModel({
    required this.id,
    required this.number,
    required this.category,
    this.isRegistered = false,
    this.isCompleted = false,
    required this.createdAt,
    this.status,
    this.windowNumber,
  });

  /// Новый конструктор из JSON ответа бэкенда
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'].toString(), // API возвращает int, приводим к String
      number: json['ticket_number'],
      category: TicketCategory.other, // Для талонов с API ставим заглушку
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
      windowNumber: json['window_number'],
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
  List<Object?> get props => [
    id,
    number,
    category,
    isRegistered,
    isCompleted,
    createdAt,
    status,
    windowNumber,
  ];
}
