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
        title: const Text('Электронный талон'),
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
                  'Ваш электронный талон',
                  style: TextStyle(fontSize: 100),
                ),
                const SizedBox(height: 100),
                Text(
                  'Услуга: ${widget.serviceName}',
                  style: const TextStyle(fontSize: 100),
                ),
                const SizedBox(height: 100),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.ticketNumber,
                    style: const TextStyle(fontSize: 100, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(height: 20),
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