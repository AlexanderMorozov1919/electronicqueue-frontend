import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/ticket_entity.dart';
import '../blocs/ticket/ticket_state.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../blocs/ticket/ticket_event.dart';

class TicketsListSection extends StatelessWidget {
  const TicketsListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        final selectedCategory = state.selectedCategory;
        final selectedTicketId = state.selectedTicket?.id;
        final tickets = selectedCategory != null
            ? state.ticketsByCategory[selectedCategory] ?? []
            : [];
        
        // --- НОВАЯ ГИБРИДНАЯ ЛОГИКА СОРТИРОВКИ ---
        tickets.sort((a, b) {
          // Функция для определения числового приоритета статуса
          int getStatusPriority(String status) {
            switch (status) {
              case 'ожидает': return 1;
              case 'зарегистрирован': return 2;
              case 'завершен': return 3;
              default: return 4;
            }
          }

          // Функция для определения, является ли талон срочным
          bool isTicketUrgent(TicketEntity ticket) {
            if (ticket.status != 'ожидает' || ticket.appointmentTime == null) {
              return false;
            }
            final now = DateTime.now();
            final diff = ticket.appointmentTime!.difference(now);
            // Срочный = опоздал ИЛИ до приема 120 минут или меньше
            return diff.isNegative || diff.inMinutes <= 120;
          }

          // 1. Главная сортировка по статусу
          final statusComparison = getStatusPriority(a.status).compareTo(getStatusPriority(b.status));
          if (statusComparison != 0) {
            return statusComparison;
          }

          // 2. Если оба талона в статусе "ожидает", применяем под-сортировку
          if (a.status == 'ожидает') {
            final isAUrgent = isTicketUrgent(a);
            final isBUrgent = isTicketUrgent(b);

            // Срочный талон всегда выше обычного
            if (isAUrgent && !isBUrgent) return -1;
            if (!isAUrgent && isBUrgent) return 1;

            // Если оба срочные, сортируем их по времени записи
            if (isAUrgent && isBUrgent) {
              return a.appointmentTime!.compareTo(b.appointmentTime!);
            }
            
            // Если оба обычные, сортируем по времени создания
            return a.createdAt.compareTo(b.createdAt);
          }

          // 3. Для всех остальных статусов сортируем по времени создания
          return a.createdAt.compareTo(b.createdAt);
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
                            final isSelected = selectedTicketId == ticket.id;
                            final canBeCalled = ticket.status == 'ожидает';

                            // Логика для визуального выделения остается той же
                            bool isUrgent = false;
                            if (ticket.status == 'ожидает' && ticket.appointmentTime != null) {
                                final now = DateTime.now();
                                final diff = ticket.appointmentTime!.difference(now);
                                if (diff.isNegative || diff.inMinutes <= 120) {
                                    isUrgent = true;
                                }
                            }

                            String statusText;
                            Color statusColor;
                            Widget? trailing;

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
                                statusColor = isUrgent ? Colors.red.shade700 : Colors.orange;
                                if (ticket.appointmentTime != null) {
                                  trailing = Text(DateFormat('HH:mm').format(ticket.appointmentTime!),
                                  style: TextStyle(
                                    color: isUrgent ? Colors.red.shade700 : Colors.black,
                                    fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal
                                  ),);
                                }
                                break;
                            }

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor:
                                  const Color(0xFF415BE7).withOpacity(0.1),
                              leading: isUrgent ? Icon(Icons.priority_high_rounded, color: Colors.red.shade700) : null,
                              title: Text(
                                ticket.number,
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              trailing: trailing,
                              onTap: canBeCalled
                                  ? () {
                                      context
                                          .read<TicketBloc>()
                                          .add(SelectTicketEvent(ticket));
                                    }
                                  : null,
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