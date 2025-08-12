import 'package:equatable/equatable.dart';

class BusinessProcessEntity extends Equatable {
  final String name;
  final bool isEnabled;

  const BusinessProcessEntity({
    required this.name,
    required this.isEnabled,
  });

  String get displayName {
    switch (name) {
      case 'terminal': return 'Терминал';
      case 'reception': return 'Табло регистратуры';
      case 'registry': return 'Окно регистратора';
      case 'doctor': return 'Окно врача';
      case 'queue_doctor': return 'Табло у кабинета врача';
      case 'schedule': return 'Общее расписание';
      case 'database': return 'Внешний API базы данных';
      case 'appointment': return 'Оформление записи (кнопка)';
      default: return name;
    }
  }

  BusinessProcessEntity copyWith({bool? isEnabled}) {
    return BusinessProcessEntity(
      name: name,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [name, isEnabled];
}