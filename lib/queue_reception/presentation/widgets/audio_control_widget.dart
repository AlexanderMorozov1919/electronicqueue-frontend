import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

class AudioControlWidget extends StatefulWidget {
  final Widget child;
  
  const AudioControlWidget({
    super.key,
    required this.child,
  });

  @override
  State<AudioControlWidget> createState() => _AudioControlWidgetState();
}

class _AudioControlWidgetState extends State<AudioControlWidget> {
  bool _showAudioPrompt = true;
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Регистрируем пользовательское взаимодействие
            _audioService.setUserInteracted();
            if (_showAudioPrompt) {
              setState(() {
                _showAudioPrompt = false;
              });
            }
          },
          child: widget.child,
        ),
        if (_showAudioPrompt)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.volume_up,
                        size: 48,
                        color: Color(0xFF415BE7),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Включить звуковые уведомления',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Нажмите на кнопку для активации звуковых уведомлений о вызове талонов',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // ИСПРАВЛЕНИЕ: Добавляем setUserInteracted() здесь
                          _audioService.setUserInteracted(); 
                          _audioService.toggleMute(); // Включаем звук
                          setState(() {
                            _showAudioPrompt = false;
                          });
                        },
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Включить звук'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF415BE7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          // Звук уже выключен, просто регистрируем клик и скрываем оверлей
                          _audioService.setUserInteracted();
                          setState(() {
                            _showAudioPrompt = false;
                          });
                        },
                        child: const Text(
                          'Продолжить без звука',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}