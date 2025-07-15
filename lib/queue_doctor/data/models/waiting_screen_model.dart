import '../../domain/entities/waiting_screen_entity.dart';

class WaitingScreenModel extends WaitingScreenEntity {
  WaitingScreenModel({
    required String doctorName,
    required String doctorSpecialty,
    required int officeNumber,
    String? currentTicket,
    bool isCalled = false,
  }) : super(
          doctorName: doctorName,
          doctorSpecialty: doctorSpecialty,
          officeNumber: officeNumber,
          currentTicket: currentTicket,
          isCalled: isCalled,
        );

  factory WaitingScreenModel.fromJson(Map<String, dynamic> json) {
    return WaitingScreenModel(
      doctorName: json['doctorName'],
      doctorSpecialty: json['doctorSpecialty'],
      officeNumber: json['officeNumber'],
      currentTicket: json['currentTicket'],
      isCalled: json['isCalled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'officeNumber': officeNumber,
      'currentTicket': currentTicket,
      'isCalled': isCalled,
    };
  }
}