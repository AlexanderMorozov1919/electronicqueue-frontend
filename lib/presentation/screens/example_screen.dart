import 'package:flutter/material.dart';
import '/domain/usecases/navigate_to_selection_usecase.dart';
import '../widgets/centered_button.dart';
import '../../data/api/ticket_api.dart';

/// Экран приветствия с кнопкой перехода к выбору услуги.
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late final Future<String> _buttonTextFuture;
  final TicketApi _api = TicketApi();

  @override
  void initState() {
    super.initState();
    _buttonTextFuture = _fetchButtonText();
  }

  Future<String> _fetchButtonText() async {
    final resp = await _api.fetchStartPage();
    return resp['button_text'] ?? 'Встать в очередь';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: _buttonTextFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Ошибка: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ));
          }
          final buttonText = snapshot.data ?? 'Встать в очередь';
          return CenteredButton(
            text: buttonText,
            onPressed: () => NavigateToSelectionUseCase()(context),
          );
        },
      ),
    );
  }
}