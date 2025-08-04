import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constans.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/ticket/ticket_state.dart';
import '../../domain/entities/ticket_entity.dart';

class NextTicketButton extends StatelessWidget {
  const NextTicketButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TicketBloc, TicketState,
        (TicketEntity?, TicketEntity?, Type)>(
      selector: (state) {
        return (state.currentTicket, state.selectedTicket, state.runtimeType);
      },
      builder: (context, data) {
        final currentTicket = data.$1;
        final selectedTicket = data.$2;
        final runtimeType = data.$3;
        final bool isAnyLoading = runtimeType == TicketLoading;

        final bool isCurrentTicketActive = currentTicket != null &&
            !currentTicket.isCompleted &&
            !currentTicket.isRegistered;

        if (selectedTicket != null) {
          final canCallSpecific = !isAnyLoading && !isCurrentTicketActive;

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canCallSpecific
                  ? () {
                      final windowNumber =
                          context.read<AuthBloc>().windowNumber ?? 1;
                      context
                          .read<TicketBloc>()
                          .add(CallSpecificTicketEvent(windowNumber));
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                backgroundColor: const Color(
                    0xFF4EB8A6), // Другой цвет для обозначения другого действия
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[400],
              ),
              child: Text('Вызвать талон ${selectedTicket.number}'),
            ),
          );
        }

        final canCallNext = !isCurrentTicketActive;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canCallNext && !isAnyLoading
                ? () {
                    final windowNumber =
                        context.read<AuthBloc>().windowNumber ?? 1;
                    final selectedCategory =
                        context.read<TicketBloc>().state.selectedCategory;
                    context.read<TicketBloc>().add(CallNextTicketEvent(
                          windowNumber: windowNumber,
                          category: selectedCategory,
                        ));
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
              backgroundColor: const Color(0xFF415BE7),
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