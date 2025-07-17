import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/queue_entity.dart';
import '../blocs/queue_bloc.dart';
import '../blocs/queue_event.dart';
import '../blocs/queue_state.dart';

class QueueStatusWidget extends StatelessWidget {
  const QueueStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        if (state is QueueLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is QueueError) {
          return Center(child: Text(state.message));
        } else if (state is QueueLoaded) {
          return _buildQueueInterface(context, state.queue);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildQueueInterface(BuildContext context, QueueEntity queue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: queue.isAppointmentInProgress
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Идет прием',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Талон ${queue.currentTicket}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
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
                  ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: queue.isAppointmentInProgress 
                  ? Colors.red 
                  : Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final bloc = context.read<QueueBloc>();
              if (queue.isAppointmentInProgress) {
                bloc.add(EndAppointmentEvent());
              } else {
                bloc.add(StartAppointmentEvent());
              }
            },
            child: Text(
              queue.isAppointmentInProgress
                  ? 'Завершить прием'
                  : 'Вызвать следующего пациента',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}