import 'package:flutter/material.dart';
import '../widgets/queue_header.dart';
import '../widgets/waiting_section.dart';
import '../widgets/called_section.dart';
import '../widgets/time_display.dart';
import '../widgets/audio_control_widget.dart';

class QueueDisplayPage extends StatelessWidget {
  const QueueDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AudioControlWidget(
        child: Column(
          children: [
            const QueueHeader(),
            Expanded(
              child: Row(
                children: [
                  // Левая часть - ожидающие
                  const Expanded(
                    flex: 2,
                    child: WaitingSection(),
                  ),
                  // Правая часть - вызываемые
                  Expanded(
                    flex: 3,
                    child: CalledSection(),
                  ),
                ],
              ),
            ),
            const TimeDisplay(),
          ],
        ),
      ),
    );
  }
}