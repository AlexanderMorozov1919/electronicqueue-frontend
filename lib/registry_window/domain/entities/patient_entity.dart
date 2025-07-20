import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final int id;
  final String fullName;
  final String? omsNumber;
  final String? passportSeries;
  final String? passportNumber;
  final DateTime? birthDate;
  final String? phone;

  const PatientEntity({
    required this.id,
    required this.fullName,
    this.omsNumber,
    this.passportSeries,
    this.passportNumber,
    this.birthDate,
    this.phone,
  });

  factory PatientEntity.fromJson(Map<String, dynamic> json) {
    return PatientEntity(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      omsNumber: json['oms_number'] as String?,
      passportSeries: json['passport_series'] as String?,
      passportNumber: json['passport_number'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null,
      phone: json['phone'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, fullName, omsNumber, passportNumber, passportSeries, birthDate, phone];
}