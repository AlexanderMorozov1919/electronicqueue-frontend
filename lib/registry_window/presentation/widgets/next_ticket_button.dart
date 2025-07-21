import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constans.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/ticket/ticket_state.dart';
import '../../domain/entities/ticket_entity.dart';

class NextTicketButton extends StatelessWidget {
  const NextTicketButton({super.key});

  bool _canCallNext(TicketEntity? ticket) {
    if (ticket == null) return true;
    return ticket.isCompleted || ticket.isRegistered;
  }

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
        final bool isEnabled = _canCallNext(currentTicket);

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled && !isAnyLoading
                ? () {
                    context.read<TicketBloc>().add(CallNextTicketEvent());
                  }
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: const Text(AppConstants.callNextButton),
          ),
        );
      },
    );
  }
}