import 'package:flutter/material.dart';
import '../models/implant_model.dart';

class ImplantAlertCard extends StatelessWidget {
  final Implant implant;
  final VoidCallback onTap;

  const ImplantAlertCard({super.key, required this.implant, required this.onTap});

  Color get _color {
    switch (implant.currentStatus) {
      case ImplantStatus.critical: return const Color(0xFFFF4444);
      case ImplantStatus.atRisk: return const Color(0xFFFF6B35);
      default: return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Alert dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tooth #${implant.position.toothNumber}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF26231F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${implant.brand} · ${implant.monthsSincePlacement}mo',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6E6860), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(implant.riskScore * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  implant.statusLabel,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

