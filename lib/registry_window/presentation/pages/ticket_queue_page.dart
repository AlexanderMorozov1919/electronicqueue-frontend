import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ticket_bloc.dart';
import '../../core/constants/app_constans.dart';
import '../../core/utils/ticket_category.dart';
import '../../domain/usecases/call_next_ticket.dart';
import '../../domain/usecases/register_current_ticket.dart';
import '../../domain/usecases/complete_current_ticket.dart';
import '../../domain/usecases/get_current_ticket.dart';
import '../../domain/usecases/get_tickets_by_category.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../presentation/blocs/ticket_event.dart';
import '../../presentation/blocs/ticket_state.dart';

class TicketQueuePage extends StatelessWidget {
  const TicketQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketBloc(
        callNextTicket: CallNextTicket(
          RepositoryProvider.of<TicketRepository>(context),
        ),
        registerCurrentTicket: RegisterCurrentTicket(
          RepositoryProvider.of<TicketRepository>(context),
        ),
        completeCurrentTicket: CompleteCurrentTicket(
          RepositoryProvider.of<TicketRepository>(context),
        ),
        getCurrentTicket: GetCurrentTicket(
          RepositoryProvider.of<TicketRepository>(context),
        ),
        getTicketsByCategory: GetTicketsByCategory(
          RepositoryProvider.of<TicketRepository>(context),
        ),
      )..add(LoadCurrentTicketEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appTitle),
          centerTitle: true,
        ),
        body: const TicketQueueView(),
      ),
    );
  }
}

class TicketQueueView extends StatelessWidget {
  const TicketQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CurrentTicketSection(),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 2, child: CategoriesSection()),
                const SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      const Expanded(child: TicketsListSection()),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<TicketBloc>().add(
                              CallNextTicketEvent(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.normal,
                            ),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(AppConstants.callNextButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentTicketSection extends StatelessWidget {
  const CurrentTicketSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        final currentTicket = state.currentTicket;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentTicket.number,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<TicketBloc>()
                                  .add(RegisterCurrentTicketEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(150, 50),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              textStyle: const TextStyle(fontSize: 18),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(AppConstants.registerButton),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<TicketBloc>()
                                  .add(CompleteCurrentTicketEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(150, 50),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              textStyle: const TextStyle(fontSize: 18),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(AppConstants.completeButton),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  const Text('Нет активного талона'),
              ],
            ),
          ),
        );
      },
    );
  }
}


class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Категории',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...TicketCategory.values.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(category.name),
                  onTap: () {
                    context.read<TicketBloc>().add(
                      LoadTicketsByCategoryEvent(category),
                    );
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

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
                  child: ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return ListTile(
                        title: Text(ticket.number),
                        subtitle: Text(
                          ticket.isCompleted ? 'Завершен' : 'В ожидании',
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
