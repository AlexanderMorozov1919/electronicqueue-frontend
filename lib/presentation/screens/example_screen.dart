import 'package:flutter/material.dart';
import '/domain/usecases/navigate_to_selection_usecase.dart';
import '../widgets/centered_button.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CenteredButton(
        text: 'Встать в очередь',
        onPressed: () => NavigateToSelectionUseCase()(context),
      ),
    );
  }
}