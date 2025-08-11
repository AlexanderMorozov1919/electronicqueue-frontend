import 'package:flutter/material.dart';
import 'example_screen.dart';
import 'dart:async';

/// Экран отображения электронного талона с таймером.
class DigitalTicketScreen extends StatefulWidget {
  final String serviceName;
  final String ticketNumber;
  final int timeout;

  const DigitalTicketScreen({
    required this.serviceName,
    required this.ticketNumber,
    required this.timeout,
    super.key,
  });

  @override
  State<DigitalTicketScreen> createState() => _DigitalTicketScreenState();
}

class _DigitalTicketScreenState extends State<DigitalTicketScreen> {
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
    final titleFontSize = screenWidth * 0.07;
    final ticketFontSize = screenWidth * 0.1;
    final timerFontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Электронный талон'),
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
                      'Ваш электронный талон',
                      style: TextStyle(fontSize: titleFontSize),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Услуга: ${widget.serviceName}',
                      style: TextStyle(fontSize: titleFontSize),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF415BE7), width: 3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.ticketNumber,
                        style: TextStyle(
                            fontSize: ticketFontSize, fontWeight: FontWeight.bold),
                      ),
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
            child: Text(
              'Закроется через: $_secondsRemaining сек.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: timerFontSize, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}