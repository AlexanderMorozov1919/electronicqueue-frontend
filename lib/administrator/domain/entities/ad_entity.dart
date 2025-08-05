import 'package:equatable/equatable.dart';

class AdEntity extends Equatable {
  final int? id;
  final String? picture;
  final int durationSec;
  final bool isEnabled;
  final bool receptionOn; 
  final bool scheduleOn;  

  const AdEntity({
    this.id,
    this.picture,
    required this.durationSec,
    required this.isEnabled,
    required this.receptionOn, 
    required this.scheduleOn,  
  });

  factory AdEntity.fromJson(Map<String, dynamic> json) {
    return AdEntity(
      id: json['id'],
      picture: json['picture'],
      durationSec: json['duration_sec'],
      isEnabled: json['is_enabled'],
      receptionOn: json['reception_on'] ?? true,
      scheduleOn: json['schedule_on'] ?? true,
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'picture': picture,
      'duration_sec': durationSec,
      'is_enabled': isEnabled,
      'reception_on': receptionOn, 
      'schedule_on': scheduleOn,   
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      if (picture != null) 'picture': picture,
      'duration_sec': durationSec,
      'is_enabled': isEnabled,
      'reception_on': receptionOn, 
      'schedule_on': scheduleOn,   
    };
  }

  AdEntity copyWith({
    int? id,
    String? picture,
    int? durationSec,
    bool? isEnabled,
    bool? receptionOn, 
    bool? scheduleOn,  
  }) {
    return AdEntity(
      id: id ?? this.id,
      picture: picture ?? this.picture,
      durationSec: durationSec ?? this.durationSec,
      isEnabled: isEnabled ?? this.isEnabled,
      receptionOn: receptionOn ?? this.receptionOn, 
      scheduleOn: scheduleOn ?? this.scheduleOn,   
    );
  }

  @override
  List<Object?> get props => [id, picture, durationSec, isEnabled, receptionOn, scheduleOn]; 
}