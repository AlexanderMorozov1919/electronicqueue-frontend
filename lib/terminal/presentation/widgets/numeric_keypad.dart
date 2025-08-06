import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildRow(['1', '2', '3'])),
        Expanded(child: _buildRow(['4', '5', '6'])),
        Expanded(child: _buildRow(['7', '8', '9'])),
        Expanded(child: _buildRow(['', '0', 'backspace'])),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: key.isEmpty
            ? const SizedBox.shrink()
            : Material(
                color: key == 'backspace'
                    ? Colors.grey.shade300
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    if (key == 'backspace') {
                      onBackspace();
                    } else {
                      onKeyPressed(key);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: key == 'backspace'
                        ? const Icon(Icons.backspace_outlined, size: 40)
                        : FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              key,
                              style: const TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}