import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../blocs/ticket/ticket_event.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  
  const ErrorStateWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ошибка: $message', 
            style: const TextStyle(color: Colors.red, fontSize: 24)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<TicketBloc>().add(LoadCurrentTicketEvent()),
            child: const Text('Попробовать снова'),
          )
        ],
      ),
    );
  }
}