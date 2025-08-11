import 'package:elqueue/registry_window/domain/usecases/call_specific_ticket.dart';
import 'package:elqueue/registry_window/presentation/widgets/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../../core/constants/app_constans.dart';
import '../../domain/usecases/call_next_ticket.dart';
import '../../domain/usecases/register_current_ticket.dart';
import '../../domain/usecases/complete_current_ticket.dart';
import '../../domain/usecases/get_current_ticket.dart';
import '../../domain/usecases/get_tickets_by_category.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../widgets/ticket_queue_view.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/auth/auth_bloc.dart';
import 'auth_page.dart';

class TicketQueuePage extends StatelessWidget {
  const TicketQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final windowNumber = authBloc.windowNumber ?? 1;

    // Оборачиваем все в BlocListener, чтобы отреагировать на событие выхода
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! AuthSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ), // Используем LoginPage из текущего модуля
            (route) => false,
          );
        }
      },
      child: BlocProvider(
        create: (context) => TicketBloc(
          callNextTicket: CallNextTicket(
            RepositoryProvider.of<TicketRepository>(context),
          ),
          callSpecificTicket: CallSpecificTicket(
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
          backgroundColor: const Color(0xFFF1F3F4),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF1F3F4),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(AppConstants.appTitle),
                const SizedBox(width: 15),
                Chip(
                  label: Text(
                    'Окно №$windowNumber',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
            centerTitle: true,
            actions: const [LogoutButton()],
          ),
          body: const TicketQueueView(),
        ),
      ),
    );
  }
}