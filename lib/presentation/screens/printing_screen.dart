import 'package:flutter/material.dart';
import 'example_screen.dart';
import 'dart:async';

/// Экран печати талона с таймером возврата на главный экран.
class PrintingScreen extends StatefulWidget {
  final String serviceName;
  final String ticketNumber;
  final int timeout;

  const PrintingScreen({
    required this.serviceName,
    required this.ticketNumber,
    required this.timeout,
    super.key,
  });

  @override
  State<PrintingScreen> createState() => _PrintingScreenState();
}

class _PrintingScreenState extends State<PrintingScreen> {
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.timeout;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ExampleScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Печать талона'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Возьмите талон',
                  style: TextStyle(fontSize: 100, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 100),
                Text(
                  'Услуга: ${widget.serviceName}',
                  style: const TextStyle(fontSize: 100),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(Icons.keyboard_arrow_down, size: 200),
                const SizedBox(height: 50),
                Text(
                  'Закроется через: $_secondsRemaining сек.',
                  style: const TextStyle(fontSize: 40, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
