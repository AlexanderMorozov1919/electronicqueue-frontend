import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
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
            onPressed: () {
              // Получаем номер окна из AuthBloc
              final windowNumber = context.read<AuthBloc>().windowNumber;
              if (windowNumber != null) {
                // Передаем обязательный параметр windowNumber
                context.read<TicketBloc>().add(LoadCurrentTicketEvent(windowNumber: windowNumber));
              }
              // Если windowNumber по какой-то причине null, кнопка ничего не сделает,
              // но это маловероятный сценарий в контексте ошибки.
            },
            child: const Text('Попробовать снова'),
          )
        ],
      ),
    );
  }
}