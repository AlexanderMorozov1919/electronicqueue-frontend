import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  final int id;
  final String fullName;
  final String specialization;

  const DoctorEntity({
    required this.id,
    required this.fullName,
    required this.specialization,
  });

  factory DoctorEntity.fromJson(Map<String, dynamic> json) {
    return DoctorEntity(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      specialization: json['specialization'] as String,
    );
  }

  @override
  List<Object?> get props => [id, fullName, specialization];
}