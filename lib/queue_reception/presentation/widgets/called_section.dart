import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/queue_display_bloc.dart';
import '../blocs/queue_display_state.dart';

class CalledSection extends StatelessWidget {
  const CalledSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueDisplayBloc, QueueDisplayState>(
      builder: (context, state) {
        if (state is! QueueDisplayLoaded) return const Center(child: CircularProgressIndicator());
        
        final calledTickets = state.tickets.where((t) => t.status == 'called').toList();
        
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
                  'ВЫЗЫВАЮТСЯ:',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: calledTickets.length,
                  itemBuilder: (ctx, index) {
                    final ticket = calledTickets[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ticket.id,
                            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.arrow_forward, size: 50),
                          Text(
                            ' ${ticket.window}',
                            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                        ],
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