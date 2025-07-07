import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ticket.dart';
import '../blocs/queue_display_bloc.dart';
import '../blocs/queue_display_state.dart';

class TicketListWidget extends StatelessWidget {
  const TicketListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueDisplayBloc, QueueDisplayState>(
      builder: (context, state) {
        if (state is! QueueDisplayLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final calledTickets = state.tickets.where((t) => t.status == 'called').toList();
        final waitingTickets = state.tickets.where((t) => t.status == 'waiting').toList();

        return Column(
          children: [
            // Вызванные талоны (крупный текст)
            Expanded(
              child: ListView.builder(
                itemCount: calledTickets.length,
                itemBuilder: (ctx, index) {
                  final ticket = calledTickets[index];
                  return TicketItem(
                    ticket: ticket,
                    isCalled: true,
                  );
                },
              ),
            ),

            // Ожидающие (мелкий текст)
            Expanded(
              child: ListView.builder(
                itemCount: waitingTickets.length,
                itemBuilder: (ctx, index) {
                  final ticket = waitingTickets[index];
                  return TicketItem(
                    ticket: ticket,
                    isCalled: false,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class TicketItem extends StatelessWidget {
  final Ticket ticket;
  final bool isCalled;

  const TicketItem({
    super.key,
    required this.ticket,
    required this.isCalled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          ticket.id,
          style: TextStyle(
            fontSize: isCalled ? 24 : 16,
            fontWeight: isCalled ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: isCalled
            ? Text('Приглашается в окно №${ticket.window}')
            : const Text('Ожидает'),
      ),
    );
  }
}