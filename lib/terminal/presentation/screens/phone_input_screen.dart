import 'dart:async';
import 'package:elqueue/terminal/presentation/screens/confirmation_screen.dart';
import 'package:elqueue/terminal/presentation/screens/example_screen.dart';
import 'package:elqueue/terminal/presentation/widgets/numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../data/api/ticket_api.dart';
import '../../domain/entities/service_entity.dart';

class PhoneInputScreen extends StatefulWidget {
  final ServiceEntity service;
  const PhoneInputScreen({super.key, required this.service});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final MaskTextInputFormatter _maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final TicketApi _api = TicketApi();
  bool _isLoading = false;

  void _onKeyPressed(String value) {
    _maskFormatter.formatEditUpdate(
      _controller.value,
      TextEditingValue(
        text: _controller.text + value,
        selection: TextSelection.collapsed(offset: _controller.text.length + 1),
      ),
    );
    setState(() {
      _controller.text = _maskFormatter.getMaskedText();
      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    });
  }

  void _onBackspace() {
    if (_controller.text.isNotEmpty) {
      final unmasked = _maskFormatter.getUnmaskedText();
      if (unmasked.isEmpty) return;
      _maskFormatter.clear();
      _maskFormatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: unmasked.substring(0, unmasked.length - 1)),
      );
      setState(() {
        _controller.text = _maskFormatter.getMaskedText();
        _controller.selection =
            TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
      });
    }
  }

  void _onClear() {
    _maskFormatter.clear();
    setState(() {
      _controller.clear();
    });
  }

  Future<void> _confirmPhone() async {
    final String userInput = _maskFormatter.getUnmaskedText();
    final String fullPhoneNumber = '7$userInput';

    if (fullPhoneNumber.length != 11) {
      _showError('Введите полный номер телефона.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _api.checkInByPhone(fullPhoneNumber);
      final ticketNumber = response['ticket_number'] as String?;
      final serviceName = response['service_name'] as String?;
      final timeout = response['timeout'] as int?;

      if (!mounted || ticketNumber == null || serviceName == null || timeout == null) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(
            serviceName: serviceName,
            ticketNumber: ticketNumber,
            timeout: timeout,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
      Timer(const Duration(seconds: 4), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ExampleScreen()),
            (route) => false,
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Введите номер телефона',
              style:
                  TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.normal)),
        ),
        centerTitle: true,
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1, vertical: screenHeight * 0.02),
          child: Column(
            children: [
              const Spacer(flex: 2),
              TextField(
                controller: _controller,
                readOnly: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenWidth * 0.06, letterSpacing: 3),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
              const Spacer(flex: 1),
              Expanded(
                flex: 12,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: NumericKeypad(
                    onKeyPressed: _onKeyPressed,
                    onBackspace: _onBackspace,
                    onClear: _onClear,
                  ),
                ),
              ),
              const Spacer(flex: 1),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: _confirmPhone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4EB8A6),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                                vertical: screenHeight * 0.025),
                            textStyle: TextStyle(fontSize: screenWidth * 0.03),
                          ),
                          child: const Text('Подтвердить'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfirmationScreen(
                                  serviceName: widget.service.title,
                                  serviceId: widget.service.id,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Продолжить без номера телефона',
                            style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}