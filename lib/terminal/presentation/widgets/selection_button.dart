import 'package:flutter/material.dart';

class SimpleButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const SimpleButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  State<SimpleButton> createState() => _SimpleButtonState();
}

class _SimpleButtonState extends State<SimpleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 150,
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