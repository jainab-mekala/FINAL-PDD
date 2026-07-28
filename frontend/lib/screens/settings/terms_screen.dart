import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/glass_container.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0720),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Terms of Access', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0720), Color(0xFF1A0D3A)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'SYSTEM OVERVIEW',
                'ImplantGuard AI™ is an advanced surveillance system designed for the early detection and risk assessment of peri-implantitis. It utilizes machine learning models trained on diverse clinical datasets to provide predictive risk scores.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                'HOW IT WORKS',
                '1. Data Input: Clinical parameters such as Age, HbA1c levels, and implant specifications are collected.\n'
                '2. AI Analysis: The system processes these inputs through our proprietary risk model.\n'
                '3. Risk Scoring: A probability score is generated, indicating the risk of implant complications.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                'DATA PROTOCOL',
                '• Profile Data: Encrypted and stored securely in our cloud database.\n'
                '• Analysis Reports: Linked to your unique user ID and stored locally for history tracking.\n'
                '• Privacy: No patient-identifiable data is processed without explicit consent.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                'CLINICAL DISCLAIMER',
                'IMPORTANT: This system is a decision-support tool meant for use by qualified dental professionals. It is NOT a diagnostic tool. AI predictions should always be verified with clinical examination and radiographic evidence.',
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'SYSTEM VERSION v2.4.0 (STABLE)',
                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.white24, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF00F0FF),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          opacity: 0.05,
          child: Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
