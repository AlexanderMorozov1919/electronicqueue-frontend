import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/queue_bloc.dart';
import '../blocs/queue_state.dart';

class QueueBreakView extends StatelessWidget {
  const QueueBreakView({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = context.select((QueueBloc bloc) => (bloc.state as QueueLoaded).queue);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Перерыв',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        const Icon(
          Icons.coffee,
          size: 64,
          color: const Color(0xFF415BE7),
        ),
        const SizedBox(height: 16),
        Text(
          '${queue.queueLength} талонов в очереди',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}