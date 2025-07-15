import 'package:flutter/material.dart';
import '../widgets/confirmation_button.dart';
import 'printing_screen.dart';
import 'digital_ticket_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final String serviceName;

  const ConfirmationScreen({required this.serviceName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение'),
        centerTitle: true,
        toolbarHeight: 90,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Вы выбрали: $serviceName',
                style: const TextStyle(fontSize: 100),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              const Text('Печатать талон?', style: TextStyle(fontSize: 100)),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConfirmationButton(
                    text: 'Да',
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PrintingScreen(serviceName: serviceName),
                      ),
                    ),
                  ),
                  const SizedBox(width: 100),
                  ConfirmationButton(
                    text: 'Нет',
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DidgitalTicketScreen(serviceName: serviceName),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
