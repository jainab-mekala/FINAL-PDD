import 'package:flutter/material.dart';
import 'glass_container.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isAlert;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        color: isAlert ? color.withOpacity(0.08) : Colors.white,
        opacity: 0.95,
        border: Border.all(
          color: isAlert ? color.withOpacity(0.3) : const Color(0xFFE8E2D9),
          width: 1.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (isAlert)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF26231F),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6E6860),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

