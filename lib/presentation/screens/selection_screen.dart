import 'package:flutter/material.dart';
import '../widgets/selection_button.dart';
import 'confirmation_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Выберите услугу',
          style: TextStyle(fontSize: 80, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        toolbarHeight: 90,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 100.0,
            vertical: 30.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleButton(
                text: 'Записаться к врачу',
                onPressed: () => _navigateToConfirmation(context, 'Записаться к врачу'),
              ),
              const SizedBox(height: 40),
              SimpleButton(
                text: 'Прием по записи',
                onPressed: () => _navigateToConfirmation(context, 'Прием по записи'),
              ),
              const SizedBox(height: 40),
              SimpleButton(
                text: 'Сдать анализы',
                onPressed: () => _navigateToConfirmation(context, 'Сдать анализы'),
              ),
              const SizedBox(height: 40),
              SimpleButton(
                text: 'Другой вопрос',
                onPressed: () => _navigateToConfirmation(context, 'Другой вопрос'),
              ),
            ],
          ), 
        ),
      ),
    );
  }

  void _navigateToConfirmation(BuildContext context, String serviceName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(serviceName: serviceName),
      ),
    );
  }
}