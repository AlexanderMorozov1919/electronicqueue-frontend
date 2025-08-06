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
      if (!mounted) {
        timer.cancel();
        return;
      }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth * 0.08;
    final timerFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.15;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Печать талона'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Возьмите талон',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Услуга: ${widget.serviceName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: titleFontSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(Icons.keyboard_arrow_down, size: iconSize),
                const SizedBox(height: 20),
                Text(
                  'Закроется через: $_secondsRemaining сек.',
                  style: TextStyle(fontSize: timerFontSize, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}