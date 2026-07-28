// risk_gauge_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';

class RiskGaugeWidget extends StatelessWidget {
  final double riskScore; // 0.0 to 1.0
  final Color color;

  const RiskGaugeWidget({super.key, required this.riskScore, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 80,
      child: CustomPaint(
        painter: _GaugePainter(riskScore: riskScore, color: color),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              '${(riskScore * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double riskScore;
  final Color color;

  _GaugePainter({required this.riskScore, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width * 0.45;
    const strokeWidth = 10.0;

    // Background arc
    final bgPaint = Paint()
      ..color = const Color(0xFFE8E2D9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * riskScore,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.riskScore != riskScore;
}

