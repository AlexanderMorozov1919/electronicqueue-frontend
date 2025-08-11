import 'package:flutter/material.dart';

class ConfirmationButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const ConfirmationButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  State<ConfirmationButton> createState() => _ConfirmationButtonState();
}

class _ConfirmationButtonState extends State<ConfirmationButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFF203AC6) : const Color(0xFF415BE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                widget.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.07,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}