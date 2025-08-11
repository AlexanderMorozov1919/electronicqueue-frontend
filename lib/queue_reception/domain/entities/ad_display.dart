import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class AdDisplay extends Equatable {
  final int id;
  final String mediaType; // "image" or "video"
  final Uint8List? imageBytes;
  final Uint8List? videoBytes;
  final int durationSec; // for images
  final int repeatCount; // for videos

  const AdDisplay({
    required this.id,
    required this.mediaType,
    this.imageBytes,
    this.videoBytes,
    required this.durationSec,
    required this.repeatCount,
  });

  factory AdDisplay.fromJson(Map<String, dynamic> json) {
    final String mediaType = json['media_type'] ?? 'none';
    Uint8List? image, video;

    if (mediaType == 'image' &&
        json['picture'] != null &&
        json['picture'].isNotEmpty) {
      image = base64Decode(json['picture']);
    } else if (mediaType == 'video' &&
        json['video'] != null &&
        json['video'].isNotEmpty) {
      video = base64Decode(json['video']);
    }

    return AdDisplay(
      id: json['id'],
      mediaType: mediaType,
      imageBytes: image,
      videoBytes: video,
      durationSec: json['duration_sec'],
      repeatCount: json['repeat_count'] ?? 1,
    );
  }

  @override
  List<Object?> get props =>
      [id, mediaType, imageBytes, videoBytes, durationSec, repeatCount];
}