import 'package:flutter/material.dart';

class RiskChip extends StatelessWidget {
  final String label;
  const RiskChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD97757).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD97757).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFD97757),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
