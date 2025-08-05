import 'package:equatable/equatable.dart';

class AdEntity extends Equatable {
  final int? id;
  final String? picture; // ИСПРАВЛЕНИЕ: Картинка теперь может быть null
  final int durationSec;
  final bool isEnabled;

  const AdEntity({
    this.id,
    this.picture, // ИСПРАВЛЕНИЕ
    required this.durationSec,
    required this.isEnabled,
  });

  factory AdEntity.fromJson(Map<String, dynamic> json) {
    return AdEntity(
      id: json['id'],
      picture: json['picture'],
      durationSec: json['duration_sec'],
      isEnabled: json['is_enabled'],
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'picture': picture,
      'duration_sec': durationSec,
      'is_enabled': isEnabled,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'picture': picture,
      'duration_sec': durationSec,
      'is_enabled': isEnabled,
    };
  }

  AdEntity copyWith({
    int? id,
    String? picture,
    int? durationSec,
    bool? isEnabled,
  }) {
    return AdEntity(
      id: id ?? this.id,
      picture: picture ?? this.picture,
      durationSec: durationSec ?? this.durationSec,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [id, picture, durationSec, isEnabled];
}