import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ticket/ticket_state.dart';
import '../blocs/ticket/ticket_bloc.dart';

class TicketsListSection extends StatelessWidget {
  const TicketsListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        final selectedCategory = state.ticketsByCategory.keys.isNotEmpty
            ? state.ticketsByCategory.keys.first
            : null;
        final tickets = selectedCategory != null
            ? state.ticketsByCategory[selectedCategory] ?? []
            : [];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCategory?.name ?? 'Выберите категорию',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: tickets.isEmpty
                      ? const Center(
                          child: Text(
                            'Нет данных для отображения.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = tickets[index];
                            return ListTile(
                              title: Text(
                                ticket.number,
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                ticket.isCompleted ? 'Завершен' : 'В ожидании',
                                style: TextStyle(
                                  color: ticket.isCompleted
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}