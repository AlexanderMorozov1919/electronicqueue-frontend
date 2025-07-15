import 'package:flutter/material.dart';
import 'example_screen.dart';
import 'dart:async';

class DidgitalTicketScreen extends StatefulWidget {
  final String serviceName;

  const DidgitalTicketScreen({required this.serviceName, super.key});

  @override
  State<DidgitalTicketScreen> createState() => _DidgitalTicketScreenState();
}

class _DidgitalTicketScreenState extends State<DidgitalTicketScreen> {
  int _secondsRemaining = 15;
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
    Navigator.pushAndRemoveUntil(context, 
    MaterialPageRoute(builder: (_) => const ExampleScreen()), 
    (route) => false,
    );
  }

  @override
  void disponse() {
    _timer.cancel();
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
                  child: const Text(
                    'Номер талона', 
                    style: TextStyle(fontSize: 100, fontWeight: FontWeight.normal),
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