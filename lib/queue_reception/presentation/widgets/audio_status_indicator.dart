import 'package:flutter/material.dart';
import 'package:elqueue/queue_reception/services/audio_service.dart';

class AudioStatusIndicator extends StatelessWidget {
  final AudioService audioService;

  const AudioStatusIndicator({
    super.key,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder будет перерисовывать виджет при изменении isMutedNotifier
    return ValueListenableBuilder<bool>(
      valueListenable: audioService.isMutedNotifier,
      builder: (context, isMuted, child) {
        final icon = isMuted ? Icons.volume_off : Icons.volume_up;
        final color = isMuted ? Colors.redAccent : Colors.green;

        // ИЗМЕНЕНИЕ: Позиционирование слева
        return Positioned(
          top: 16,
          left: 16, 
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Регистрируем взаимодействие и переключаем звук
                audioService.setUserInteracted();
                audioService.toggleMute();
              },
              // ИЗМЕНЕНИЕ: Делаем кнопку круглой
              customBorder: const CircleBorder(),
              child: Ink(
                // ИЗМЕНЕНИЕ: Форма круга и убираем текст
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}