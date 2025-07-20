import '../../domain/entities/waiting_screen_entity.dart';

class WaitingScreenModel extends WaitingScreenEntity {
  const WaitingScreenModel({
    required super.doctorName,
    required super.doctorSpecialty,
    required super.officeNumber,
    super.currentTicket,
    required super.isCalled,
  });

  factory WaitingScreenModel.fromJson(Map<String, dynamic> json) {
    final bool isWaiting = json['is_waiting'] ?? true;

    return WaitingScreenModel(
      doctorName: json['doctor_name'] as String,
      doctorSpecialty: json['doctor_specialty'] as String,
      officeNumber: json['office_number'] as int,
      currentTicket: json['ticket_number'] as String?,
      isCalled: !isWaiting,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_name': doctorName,
      'doctor_specialty': doctorSpecialty,
      'office_number': officeNumber,
      'ticket_number': currentTicket,
      'is_waiting': !isCalled,
    };
  }
}