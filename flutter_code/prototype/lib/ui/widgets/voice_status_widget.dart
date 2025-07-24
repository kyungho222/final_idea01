import 'package:flutter/material.dart';

class VoiceStatusWidget extends StatelessWidget {
  final bool isListening;
  final String statusMessage;

  const VoiceStatusWidget({
    super.key,
    required this.isListening,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isListening ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isListening ? Icons.mic : Icons.mic_off,
            color: isListening ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusMessage,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
} 