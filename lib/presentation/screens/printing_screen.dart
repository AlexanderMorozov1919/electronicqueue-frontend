import 'package:flutter/material.dart';
import 'example_screen.dart';
import 'dart:async';

class PrintingScreen extends StatefulWidget {
  final String serviceName;

  const PrintingScreen({required this.serviceName, super.key});

  @override
  State<PrintingScreen> createState() => _PrintingScreenState();
}

class _PrintingScreenState extends State<PrintingScreen> {
  int _secondsRemaining = 10;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          _navigateToExampleScreen();
        }
      });
    });
  }

  void _navigateToExampleScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ExampleScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timer.cancel(); 
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
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.normal,
                  ),
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
                Icon(Icons.keyboard_arrow_down, size: 200),
                SizedBox(height: 50),
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
