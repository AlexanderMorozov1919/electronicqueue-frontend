import 'package:flutter/material.dart';
import '../../presentation/screens/selection_screen.dart';

class NavigateToSelectionUseCase {
  void call(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectionScreen()),
    );
  }
}