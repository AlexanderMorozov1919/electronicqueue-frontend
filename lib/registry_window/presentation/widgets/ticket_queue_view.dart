import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ticket/ticket_state.dart';
import 'loading_state_widget.dart';
import 'error_state_widget.dart';
import 'current_ticket_section.dart';
import 'categories_section.dart';
import 'tickets_list_section.dart';
import 'next_ticket_button.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../blocs/ticket/ticket_event.dart';

class TicketQueueView extends StatelessWidget {
  const TicketQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      listenWhen: (previous, current) =>
          previous.infoMessage != current.infoMessage &&
          current.infoMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.infoMessage!),
            backgroundColor: Colors.blueAccent,
          ),
        );
        context.read<TicketBloc>().add(ClearInfoMessageEvent());
      },
      child: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketError) {
            return ErrorStateWidget(message: state.message);
          }
          
          return Stack(
            children: [
              _buildMainContent(context),           
              if (state is TicketInitial || (state is TicketLoading && state.currentTicket == null))
                const LoadingStateWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
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
                      const NextTicketButton(),
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