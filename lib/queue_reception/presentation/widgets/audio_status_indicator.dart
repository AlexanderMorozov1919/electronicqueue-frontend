import 'package:flutter/material.dart';

class AudioStatusIndicator extends StatefulWidget {
  const AudioStatusIndicator({super.key});

  @override
  State<AudioStatusIndicator> createState() => _AudioStatusIndicatorState();
}

class _AudioStatusIndicatorState extends State<AudioStatusIndicator> {
  bool _isAudioEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isAudioEnabled ? Colors.green : Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isAudioEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              _isAudioEnabled ? 'Звук включен' : 'Звук выключен',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Слушаем клики по экрану для активации звука
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAudioStatus();
    });
  }

  void _checkAudioStatus() {
    // Здесь можно добавить логику проверки статуса аудио
    // Пока просто показываем, что звук нужно включить
  }
}