import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/report/report_bloc.dart';
import '../blocs/ticket/ticket_state.dart';
import 'daily_report_dialog.dart';
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
                Expanded(
                  flex: 2,
                  // ИЗМЕНЕНИЕ: Оборачиваем категории и новую кнопку в Column
                  child: Column(
                    children: [
                      const Expanded(child: CategoriesSection()),
                      const SizedBox(height: 20),
                      _buildViewTicketsButton(context),
                    ],
                  ),
                ),
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

  // НОВЫЙ ВИДЖЕТ-МЕТОД
  Widget _buildViewTicketsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<ReportBloc>(),
              child: const DailyReportDialog(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: const Color(0xFF415BE7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Просмотреть талоны'),
      ),
    );
  }
}