import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constans.dart';
import '../blocs/ticket/ticket_state.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../../domain/entities/ticket_entity.dart';

class CurrentTicketSection extends StatelessWidget {
  const CurrentTicketSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        if (state is! TicketLoaded) {
          return _buildLoadingState();
        }
        return _buildTicketState(context, state);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Загрузка...'),
      ),
    );
  }

  Widget _buildTicketState(BuildContext context, TicketLoaded state) {
    final currentTicket = state.currentTicket;
    final isTicketActive = currentTicket != null && 
                         !currentTicket.isCompleted && 
                         !currentTicket.isRegistered;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppConstants.currentTicketLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (currentTicket != null) 
              _buildActiveTicket(context, currentTicket, isTicketActive)
            else 
              const Text('Нет активного талона. Нажмите "Вызвать следующего".'),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTicket(
    BuildContext context, 
    TicketEntity ticket, 
    bool isActive
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          ticket.number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        Row(
          children: [
            _buildRegisterButton(context, isActive),
            const SizedBox(width: 10),
            _buildCompleteButton(context, isActive),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context, bool isActive) {
    return ElevatedButton(
      onPressed: isActive ? () {
        context.read<TicketBloc>().add(RegisterCurrentTicketEvent());
      } : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(AppConstants.registerButton),
    );
  }

  Widget _buildCompleteButton(BuildContext context, bool isActive) {
    return ElevatedButton(
      onPressed: isActive ? () {
        context.read<TicketBloc>().add(CompleteCurrentTicketEvent());
      } : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(AppConstants.completeButton),
    );
  }
}