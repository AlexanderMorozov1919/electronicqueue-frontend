import 'dart:convert';
import 'dart:typed_data';

class AdDisplay {
  final Uint8List picture;
  final int durationSec;

  AdDisplay({required this.picture, required this.durationSec});

  factory AdDisplay.fromJson(Map<String, dynamic> json) {
    return AdDisplay(
      picture: base64Decode(json['picture'] as String),
      durationSec: json['duration_sec'] as int,
    );
  }
}