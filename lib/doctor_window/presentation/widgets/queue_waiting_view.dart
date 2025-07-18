import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/queue_bloc.dart';
import '../blocs/queue_state.dart';

class QueueWaitingView extends StatelessWidget {
  const QueueWaitingView({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = context.select((QueueBloc bloc) => (bloc.state as QueueLoaded).queue);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Очередь',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${queue.queueLength} талонов',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}