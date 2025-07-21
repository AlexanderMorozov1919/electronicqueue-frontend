import '../../domain/entities/waiting_screen_entity.dart';

class WaitingScreenModel extends WaitingScreenEntity {
  const WaitingScreenModel({
    required super.doctorName,
    required super.doctorSpecialty,
    required super.cabinetNumber,
    super.currentTicket,
    required super.isCalled,
    super.message,
  });

  factory WaitingScreenModel.fromJson(Map<String, dynamic> json) {
    // Если doctor_name пустой, значит, приема нет
    final bool hasReception = (json['doctor_name'] as String? ?? '').isNotEmpty;
    // Если приема нет, то is_waiting не имеет значения, но для консистентности считаем что "ожидаем"
    // Если прием есть, смотрим на is_waiting
    final bool isWaiting = hasReception ? (json['is_waiting'] ?? true) : true;

    return WaitingScreenModel(
      doctorName: json['doctor_name'] as String? ?? '',
      doctorSpecialty: json['doctor_specialty'] as String? ?? '',
      cabinetNumber: json['cabinet_number'] as int,
      currentTicket: json['ticket_number'] as String?,
      isCalled: !isWaiting,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_name': doctorName,
      'doctor_specialty': doctorSpecialty,
      'cabinet_number': cabinetNumber,
      'ticket_number': currentTicket,
      'is_waiting': !isCalled,
      'message': message,
    };
  }
}