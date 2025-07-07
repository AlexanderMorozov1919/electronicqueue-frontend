import 'package:flutter/material.dart';

class QueueHeader extends StatelessWidget {
  const QueueHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blue[800],
      ),
      child: const Center(
        child: Text(
          'ОЧЕРЕДЬ В РЕГИСТРАТУРУ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}