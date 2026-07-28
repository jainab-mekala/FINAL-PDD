// gradient_button.dart
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final List<Color>? colors;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColors = colors ?? [
      const Color(0xFFD97757),
      const Color(0xFFC15C3D),
    ];

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: onPressed == null
            ? const LinearGradient(colors: [Color(0xFFE8E2D9), Color(0xFFD8D2C7)])
            : LinearGradient(
                colors: buttonColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: buttonColors[0].withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

