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
    return BlocConsumer<QueueBloc, QueueState>(
      listenWhen: (previous, current) =>
          current is QueueLoaded && current.infoMessage != null,
      listener: (context, state) {
        if (state is QueueLoaded && state.infoMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.infoMessage!),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is QueueLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is QueueError) {
          return Center(child: Text(state.message));
        } else if (state is QueueLoaded) {
          return _buildQueueInterface(context, state.queue);
        }
        return const Center(child: Text("Неопределенное состояние"));
      },
    );
  }

  Widget _buildQueueInterface(BuildContext context, QueueEntity queue) {
    final bool canCallNext = !queue.isAppointmentInProgress && 
                           !queue.isOnBreak && 
                           queue.queueLength > 0;
    final bool canStartBreak = !queue.isAppointmentInProgress && !queue.isOnBreak;
    final bool canEndBreak = queue.isOnBreak;

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
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Талон ${queue.currentTicket}',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  )
                : queue.isOnBreak
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Перерыв',
                            style: TextStyle(
                              fontSize: 30,
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
                              fontSize: 30,
                              color: Colors.black54,
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
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${queue.queueLength} талонов',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        if (canStartBreak || canEndBreak)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canEndBreak ? const Color(0xFF4EB8A6) : Color(0xFFFFA100),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final bloc = context.read<QueueBloc>();
                  if (canEndBreak) {
                    bloc.add(EndBreakEvent());
                  } else {
                    bloc.add(StartBreakEvent());
                  }
                },
                child: Text(
                  canEndBreak ? 'Завершить перерыв' : 'Начать перерыв',
                  style: const TextStyle(fontSize: 29, color: Colors.white),
                ),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: queue.isAppointmentInProgress
                  ? const Color(0xFFF44336)
                  : (canCallNext ? const Color(0xFF415BE7) : Colors.grey),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: queue.isAppointmentInProgress || canCallNext
                ? () {
                    final bloc = context.read<QueueBloc>();
                    if (queue.isAppointmentInProgress) {
                      bloc.add(EndAppointmentEvent());
                    } else {
                      bloc.add(StartAppointmentEvent());
                    }
                  }
                : null,
            child: Text(
              queue.isAppointmentInProgress
                  ? 'Завершить прием'
                  : 'Вызвать следующего пациента',
              style: const TextStyle(fontSize: 29, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}