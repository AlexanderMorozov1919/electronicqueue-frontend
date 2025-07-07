import 'package:flutter/material.dart';

class CenteredButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Duration animationDuration;

  const CenteredButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<CenteredButton> createState() => _CenteredButtonState();
}

class _CenteredButtonState extends State<CenteredButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: _isPressed 
                ? const Color.fromARGB(255, 41, 92, 139) 
                : Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white, fontSize: 100),
          ),
        ),
      ),
    );
  }
}