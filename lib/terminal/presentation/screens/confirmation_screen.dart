import 'package:flutter/material.dart';
import '../../data/api/ticket_api.dart';
import '../widgets/confirmation_button.dart';
import 'printing_screen.dart';
import 'digital_ticket_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final String serviceName;
  final String? serviceId;
  final String? ticketNumber;
  final int? timeout;

  const ConfirmationScreen({
    required this.serviceName,
    this.serviceId,
    this.ticketNumber,
    this.timeout,
    super.key,
  }) : assert(serviceId != null || ticketNumber != null);

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
      String finalTicketNumber;
      int finalTimeout;

      if (widget.ticketNumber != null) {
        // Талон уже создан (пришли с экрана ввода телефона)
        finalTicketNumber = widget.ticketNumber!;
        finalTimeout = widget.timeout ?? 15;
      } else {
        // Талон нужно создать (пришли с экрана выбора услуг)
        final resp = await _api.confirmAction(widget.serviceId!, action);
        finalTicketNumber = resp['ticket_number'] ?? '';
        finalTimeout = resp['timeout'] ?? 15;
      }

      if (!mounted) return;

      final nextScreen = action == 'print_ticket'
          ? PrintingScreen(
              serviceName: widget.serviceName,
              ticketNumber: finalTicketNumber,
              timeout: finalTimeout,
            )
          : DigitalTicketScreen(
              serviceName: widget.serviceName,
              ticketNumber: finalTicketNumber,
              timeout: finalTimeout,
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
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double titleFontSize = constraints.maxWidth * 0.08;
          final double questionFontSize = constraints.maxWidth * 0.07;
          final double spacing = constraints.maxHeight * 0.05;

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Вы выбрали: ${widget.serviceName}',
                      style: TextStyle(fontSize: titleFontSize),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing),
                    Text('Печатать талон?',
                        style: TextStyle(fontSize: questionFontSize)),
                    SizedBox(height: spacing),
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
                            SizedBox(width: constraints.maxWidth * 0.05),
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
          );
        },
      ),
    );
  }
}