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
        final selectedCategory = state.selectedCategory;
        final tickets = selectedCategory != null
            ? state.ticketsByCategory[selectedCategory] ?? []
            : [];

        tickets.sort((a, b) {
          int getStatusPriority(String status) {
            switch (status) {
              case 'ожидает': return 1;
              case 'зарегистрирован': return 2;
              case 'завершен': return 3;
              default: return 4;
            }
          }
          return getStatusPriority(a.status).compareTo(getStatusPriority(b.status));
        });

        return Card(
          color: Colors.white,
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
                            
                            String statusText;
                            Color statusColor;

                            switch (ticket.status) {
                              case 'завершен':
                                statusText = 'Завершен';
                                statusColor = Colors.green;
                                break;
                              case 'зарегистрирован':
                                statusText = 'Зарегистрирован';
                                statusColor = Colors.blue;
                                break;
                              case 'ожидает':
                              default:
                                statusText = 'В ожидании';
                                statusColor = Colors.orange;
                                break;
                            }

                            return ListTile(
                              title: Text(
                                ticket.number,
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
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