import 'package:flutter/material.dart';
import '../../data/api/ticket_api.dart';
import '../widgets/confirmation_button.dart';
import 'printing_screen.dart';
import 'digital_ticket_screen.dart';

/// Экран подтверждения действия пользователя (печать или электронный талон).
class ConfirmationScreen extends StatefulWidget {
  final String serviceName;
  final String serviceId;

  const ConfirmationScreen({
    required this.serviceName,
    required this.serviceId,
    super.key,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _loading = false;
  String? _error;
  final TicketApi _api = TicketApi();

  Future<void> _confirm(String action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await _api.confirmAction(widget.serviceId, action);
      final ticketNumber = resp['ticket_number'] ?? '';
      final timeout = resp['timeout'] ?? 15;
      if (!mounted) return;
      final nextScreen = action == 'print_ticket'
          ? PrintingScreen(
              serviceName: widget.serviceName,
              ticketNumber: ticketNumber,
              timeout: timeout,
            )
          : DigitalTicketScreen(
              serviceName: widget.serviceName,
              ticketNumber: ticketNumber,
              timeout: timeout,
            );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Подтверждение'),
        centerTitle: true,
        toolbarHeight: 90,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Вы выбрали: ${widget.serviceName}',
                  style: const TextStyle(fontSize: 100),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                const Text('Печатать талон?', style: TextStyle(fontSize: 100)),
                const SizedBox(height: 60),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConfirmationButton(
                          text: 'Да',
                          onPressed: () => _confirm('print_ticket'),
                        ),
                        const SizedBox(width: 100),
                        ConfirmationButton(
                          text: 'Нет',
                          onPressed: () => _confirm('digital_ticket'),
                        ),
                      ],
                    ),
                    if (_loading)
                      Container(
                        color: const Color.fromRGBO(255, 255, 255, 0.7),
                        child: const CircularProgressIndicator(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
