import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constans.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/ticket/ticket_bloc.dart';

class NextTicketButton extends StatelessWidget {
  final bool enabled;

  const NextTicketButton({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled
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
  }
}