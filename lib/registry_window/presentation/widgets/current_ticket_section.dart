import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constans.dart';
import '../blocs/appointment/appointment_bloc.dart';
import '../blocs/ticket/ticket_state.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../../domain/entities/ticket_entity.dart';
import 'appointment_dialog.dart';

class CurrentTicketSection extends StatelessWidget {
  const CurrentTicketSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TicketBloc, TicketState, (TicketEntity?, Type)>(
      selector: (state) {
        return (state.currentTicket, state.runtimeType);
      },
      builder: (context, data) {
        final currentTicket = data.$1;
        final runtimeType = data.$2;
        final bool isAnyLoading = runtimeType == TicketLoading;
        return _buildTicketState(context, currentTicket, isAnyLoading);
      },
    );
  }

  Widget _buildTicketState(BuildContext context, TicketEntity? currentTicket, bool isAnyLoading) {
    final bool isTicketActive = currentTicket != null &&
        !currentTicket.isCompleted &&
        !currentTicket.isRegistered;

    return Card(
      color: const Color(0xFFF1F3F4),
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
              _buildActiveTicket(context, currentTicket, isTicketActive, isAnyLoading)
            else
              const Text('Нет активного талона. Нажмите "Вызвать следующего".'),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTicket(
      BuildContext context, TicketEntity ticket, bool isActive, bool isAnyLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          ticket.number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        Row(
          children: [
            _buildRegisterButton(context, ticket, isActive, isAnyLoading),
            const SizedBox(width: 10),
            _buildCompleteButton(context, isActive, isAnyLoading),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context, TicketEntity ticket, bool isActive, bool isAnyLoading) {
    return ElevatedButton(
      onPressed: isActive && !isAnyLoading
          ? () {
              showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => MultiBlocProvider(
                  providers: [
                     BlocProvider.value(value: context.read<AppointmentBloc>()),
                     BlocProvider.value(value: context.read<TicketBloc>()),
                  ],
                  child: AppointmentDialog(ticketId: ticket.id),
                ),
              ).then((isSuccess) {
                if (isSuccess == true) {
                  context.read<TicketBloc>().add(RegisterCurrentTicketEvent());
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пациент успешно записан!'), backgroundColor: Colors.green),
                  );
                }
              });
            }
          : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: const Color(0xFF4EB8A6),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(AppConstants.registerButton),
    );
  }

  Widget _buildCompleteButton(BuildContext context, bool isActive, bool isAnyLoading) {
    return ElevatedButton(
      onPressed: isActive && !isAnyLoading
          ? () {
              context.read<TicketBloc>().add(CompleteCurrentTicketEvent());
            }
          : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: const Color(0xFFFFA100),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(AppConstants.completeButton),
    );
  }
}