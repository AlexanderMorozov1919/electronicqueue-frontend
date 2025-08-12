import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final int id;
  final String name;
  final String letter;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.letter,
  });

  factory ServiceEntity.fromJson(Map<String, dynamic> json) {
    return ServiceEntity(
      id: json['id'] as int,
      name: json['title'] as String,
      letter: json['letter'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, letter];
}