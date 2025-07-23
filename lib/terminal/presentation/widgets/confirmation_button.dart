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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: _isPressed
              ? const Color(0xFF203AC6)
              : const Color(0xFF415BE7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white, fontSize: 100),
          ),
        ),
      ),
    );
  }
}