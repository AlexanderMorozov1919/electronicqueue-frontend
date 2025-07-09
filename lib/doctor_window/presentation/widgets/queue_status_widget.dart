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
      builder: (BuildContext context, QueueState state) { 
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
                      Text(
                        'Талон ${queue.currentTicket}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Очередь: ${queue.queueLength} талонов',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              
            ),
            onPressed: () {
              final bloc = BlocProvider.of<QueueBloc>(context, listen: false);
              
              if (queue.isAppointmentInProgress) {
                bloc.add(EndAppointmentEvent());
              } else {
                final nextTicket = 'A${45 + queue.queueLength}';
                bloc.add(StartAppointmentEvent(nextTicket));
              }
            },
            child: Text(
              queue.isAppointmentInProgress
                  ? 'Завершить прием'
                  : 'Вызвать следующего пациента',
              style: const TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}