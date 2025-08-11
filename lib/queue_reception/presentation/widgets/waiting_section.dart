import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/queue_display_bloc.dart';
import '../blocs/queue_display_state.dart';

class WaitingSection extends StatelessWidget {
  const WaitingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueDisplayBloc, QueueDisplayState>(
      builder: (context, state) {
        if (state is! QueueDisplayLoaded) return const Center(child: CircularProgressIndicator());
        
        final waitingTickets = state.tickets.where((t) => t.status == 'waiting').toList();
        
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFA1A8B8)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'ОЖИДАЮТ ПРИГЛАШЕНИЯ',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: waitingTickets.length,
                  itemBuilder: (ctx, index) {
                    final ticket = waitingTickets[index];
                    return ListTile(
                      title: Center(
                        child: Text(
                          ticket.id,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}