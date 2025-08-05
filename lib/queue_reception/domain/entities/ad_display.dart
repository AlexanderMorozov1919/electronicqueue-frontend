import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // ИМПОРТ для ImageProvider

class AdDisplay extends Equatable {
  final int id;
  // ИЗМЕНЕНО: Храним готовый ImageProvider вместо сырых байтов
  final ImageProvider picture;
  final int durationSec;

  const AdDisplay({
    required this.id,
    required this.picture,
    required this.durationSec,
  });

  factory AdDisplay.fromJson(Map<String, dynamic> json) {
    // Декодирование происходит здесь, ОДИН РАЗ
    final Uint8List pictureBytes = base64Decode(json['picture']);

    return AdDisplay(
      id: json['id'],
      // Создаем MemoryImage, который является ImageProvider
      picture: MemoryImage(pictureBytes),
      durationSec: json['duration_sec'],
    );
  }

  @override
  // ИЗМЕНЕНО: ImageProvider не имеет стабильного ==, поэтому для сравнения используем id
  List<Object> get props => [id, durationSec];
}