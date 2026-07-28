import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/glass_container.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0720),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Privacy Protocol', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
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
              _buildPrivacyHeader(),
              const SizedBox(height: 32),
              _buildPrivacySection(
                'DATA MINING & COLLECTION',
                'We collect minimal clinical metadata required for risk calculation. This includes age, medical history (diabetes status, HbA1c), and clinical observations. This data is used solely for generating your risk reports.',
                Icons.analytics_outlined,
              ),
              const SizedBox(height: 20),
              _buildPrivacySection(
                'STORAGE SECRECY',
                'Your data is protected by industry-standard encryption. Local reports are sandboxed within the application, while cloud profiles are stored in partitioned, encrypted Firestore instances.',
                Icons.enhanced_encryption_outlined,
              ),
              const SizedBox(height: 20),
              _buildPrivacySection(
                'USER SOVEREIGNTY',
                'You maintain full control over your data. You may request data deletion or export your analysis history at any time through the Profile Management terminal.',
                Icons.person_search_outlined,
              ),
              const SizedBox(height: 20),
              _buildPrivacySection(
                'AI ETHICS',
                'Our AI models do not "learn" from your specific patient data unless you explicitly opt into our Clinical Research Program. Your private reports are never used for public model training.',
                Icons.psychology_alt_outlined,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00F0FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.2)),
          ),
          child: Text(
            'ENCRYPTION ACTIVE',
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF00F0FF), letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your data is your legacy.',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'We follow strict medical data privacy protocols (GDPR & HIPAA compliant framework).',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(String title, String content, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF00F0FF)),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white60, height: 1.5),
          ),
        ],
      ),
    );
  }
}
