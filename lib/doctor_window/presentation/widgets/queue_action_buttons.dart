import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/queue_entity.dart';
import '../blocs/queue_bloc.dart';
import '../blocs/queue_event.dart';

class QueueActionButtons extends StatelessWidget {
  final QueueEntity queue;
  
  const QueueActionButtons({super.key, required this.queue});

  @override
  Widget build(BuildContext context) {
    final bool canCallNext = !queue.isAppointmentInProgress && 
                           !queue.isOnBreak && 
                           queue.queueLength > 0;
    final bool canStartBreak = !queue.isAppointmentInProgress && !queue.isOnBreak;
    final bool canEndBreak = queue.isOnBreak;

    return Column(
      children: [
        if (canStartBreak || canEndBreak)
          _buildBreakButton(context, canEndBreak),
        _buildAppointmentButton(context, canCallNext),
      ],
    );
  }

  Widget _buildBreakButton(BuildContext context, bool isBreakActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isBreakActive ? const Color(0xFF4EB8A6) : const Color(0xFFFFA100),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            final bloc = context.read<QueueBloc>();
            isBreakActive 
              ? bloc.add(EndBreakEvent())
              : bloc.add(StartBreakEvent());
          },
          child: Text(
            isBreakActive ? 'Завершить перерыв' : 'Начать перерыв',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentButton(BuildContext context, bool canCallNext) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: queue.isAppointmentInProgress
              ? Colors.red
              : (canCallNext ? Colors.blue : Colors.grey),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: queue.isAppointmentInProgress || canCallNext
            ? () {
                final bloc = context.read<QueueBloc>();
                queue.isAppointmentInProgress
                  ? bloc.add(EndAppointmentEvent())
                  : bloc.add(StartAppointmentEvent());
              }
            : null,
        child: Text(
          queue.isAppointmentInProgress
              ? 'Завершить прием'
              : 'Вызвать следующего пациента',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}