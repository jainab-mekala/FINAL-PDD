import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/glass_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0720),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('System Information', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0720), Color(0xFF1A0D3A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF00F0FF), Color(0xFFAA55FF)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.3), blurRadius: 30)],
                  ),
                  child: const Icon(Icons.shield_rounded, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Text('ImplantGuard AI™', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('Clinical Risk Surveillance', style: GoogleFonts.outfit(fontSize: 14, color: Colors.white38, letterSpacing: 1.5)),
                const SizedBox(height: 48),
                _buildInfoRow('SYSTEM VERSION', 'v2.4.0 (STABLE)'),
                _buildInfoRow('BUILD ID', '2026.04.30.0718'),
                _buildInfoRow('NEURAL ENGINE', 'v4.2.1-MED'),
                _buildInfoRow('ENCRYPTION', 'AES-256-GCM'),
                _buildInfoRow('CLOUD SYNC', 'ACTIVE'),
                const SizedBox(height: 48),
                Text(
                  '© 2026 ImplantGuard Technologies.\nAll biological and clinical data processed\nunder global privacy standards.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white24, height: 1.5),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        opacity: 0.05,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 1)),
            Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF00F0FF))),
          ],
        ),
      ),
    );
  }
}
