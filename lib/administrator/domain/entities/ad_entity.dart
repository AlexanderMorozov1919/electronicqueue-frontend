import 'package:equatable/equatable.dart';

class AdEntity extends Equatable {
  final int? id;
  final String? picture; // base64
  final String? video; // base64
  final String mediaType; // "image", "video", "none"
  final int durationSec;
  final int repeatCount;
  final bool isEnabled;
  final bool receptionOn;
  final bool scheduleOn;

  const AdEntity({
    this.id,
    this.picture,
    this.video,
    required this.mediaType,
    required this.durationSec,
    required this.repeatCount,
    required this.isEnabled,
    required this.receptionOn,
    required this.scheduleOn,
  });

  factory AdEntity.fromJson(Map<String, dynamic> json) {
    return AdEntity(
      id: json['id'],
      picture: json['picture'],
      video: json['video'],
      mediaType: json['media_type'] ?? 'none',
      durationSec: json['duration_sec'],
      repeatCount: json['repeat_count'] ?? 1,
      isEnabled: json['is_enabled'],
      receptionOn: json['reception_on'] ?? true,
      scheduleOn: json['schedule_on'] ?? true,
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      if (picture != null) 'picture': picture,
      if (video != null) 'video': video,
      'duration_sec': durationSec,
      'repeat_count': repeatCount,
      'is_enabled': isEnabled,
      'reception_on': receptionOn,
      'schedule_on': scheduleOn,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'picture': picture,
      'video': video,
      'duration_sec': durationSec,
      'repeat_count': repeatCount,
      'is_enabled': isEnabled,
      'reception_on': receptionOn,
      'schedule_on': scheduleOn,
    };
  }

  AdEntity copyWith({
    int? id,
    String? picture,
    String? video,
    String? mediaType,
    int? durationSec,
    int? repeatCount,
    bool? isEnabled,
    bool? receptionOn,
    bool? scheduleOn,
  }) {
    return AdEntity(
      id: id ?? this.id,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      mediaType: mediaType ?? this.mediaType,
      durationSec: durationSec ?? this.durationSec,
      repeatCount: repeatCount ?? this.repeatCount,
      isEnabled: isEnabled ?? this.isEnabled,
      receptionOn: receptionOn ?? this.receptionOn,
      scheduleOn: scheduleOn ?? this.scheduleOn,
    );
  }

  @override
  List<Object?> get props => [
        id,
        picture,
        video,
        mediaType,
        durationSec,
        repeatCount,
        isEnabled,
        receptionOn,
        scheduleOn
      ];
}