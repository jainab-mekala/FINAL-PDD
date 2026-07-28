import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction_result.dart';
import '../widgets/gradient_button.dart';

class ResultScreen extends StatelessWidget {
  final PredictionResult result;
  const ResultScreen({super.key, required this.result});

  Color get _riskColor {
    if (result.riskLevel.toLowerCase().contains("low"))
      return const Color(0xFF00FF9F);
    if (result.riskLevel.toLowerCase().contains("moderate"))
      return const Color(0xFFFFD700);
    return const Color(0xFFFF4444);
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'DIAGNOSTIC REPORT',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: color.withOpacity(0.12),
                                      blurRadius: 40,
                                      spreadRadius: 6),
                                ],
                              ),
                            ),
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: color, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${result.score}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 54,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: -2,
                                    ),
                                  ),
                                  Text(
                                    "RISK SCORE",
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: color.withOpacity(0.4), width: 1.5),
                        ),
                        child: Text(
                          result.riskLevel.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: color,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: Color(0xFF0284C7), size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'CLINICAL INSIGHT',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF0284C7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              result.message,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                color: const Color(0xFF475569),
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      GradientButton(
                        text: 'VIEW CLINICAL PROTOCOLS',
                        onPressed: () => context.push('/suggestions'),
                        icon: Icons.lightbulb_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF0284C7), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 20, color: Color(0xFF0284C7)),
                              const SizedBox(width: 8),
                              Text('ACKNOWLEDGE & CLOSE',
                                  style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0284C7),
                                      letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'This analysis is AI-generated and should be reviewed by a clinical professional.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
