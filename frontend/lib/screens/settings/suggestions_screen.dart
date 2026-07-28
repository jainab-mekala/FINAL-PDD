import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_bottom_nav.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  double? _lastScore;
  String? _riskLevel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLastResult();
  }

  Future<void> _loadLastResult() async {
    final user = FirebaseAuth.instance.currentUser;
    final key = user != null ? 'analyzer_history_${user.uid}' : 'analyzer_history_public';
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(key);

    if (history != null && history.isNotEmpty) {
      final lastEntry = jsonDecode(history.first);
      setState(() {
        _lastScore = (lastEntry['score'] as num).toDouble();
        _riskLevel = lastEntry['condition'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFFAF7F2), Color(0xFFF5F0E8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD97757)))
                    : _lastScore == null
                        ? _buildEmptyState()
                        : _buildSuggestionsList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97757),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'CLINICAL INTELLIGENCE',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97757),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Smart Suggestions',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF26231F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5ECE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb_outline_rounded, size: 48, color: Color(0xFFD97757)),
            ),
            const SizedBox(height: 24),
            Text(
              'No Analysis Data',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF26231F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Run an AI analysis to see clinical suggestions here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF6E6860),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    final score = _lastScore! * 100;
    final suggestions = _getSuggestionsForScore(score);
    final color = _getColorForScore(score);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Score summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8E2D9)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26231F).withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.analytics_rounded, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAST ANALYSIS',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF6E6860),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${score.toStringAsFixed(1)}% Risk Score',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF26231F),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _riskLevel?.toUpperCase() ?? 'IDENTIFIED',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97757),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'RECOMMENDED PROTOCOLS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97757),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.map((s) => _buildSuggestionCard(s)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E2D9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26231F).withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5ECE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(suggestion['icon'] as IconData, color: const Color(0xFFD97757), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion['title'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF26231F),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    suggestion['desc'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF6E6860),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForScore(double score) {
    if (score >= 75) return const Color(0xFFDC2626);
    if (score >= 50) return const Color(0xFFE65100);
    if (score >= 25) return const Color(0xFFD97706);
    return const Color(0xFF388E3C);
  }

  List<Map<String, dynamic>> _getSuggestionsForScore(double score) {
    if (score >= 75) {
      return [
        {'title': 'Immediate Clinical Intervention', 'desc': 'High probability of active disease. Radiographic assessment and potential surgical consult required.', 'icon': Icons.emergency_rounded},
        {'title': 'Pathogen Control', 'desc': 'Prescribe systemic antibiotics and antimicrobial rinses (Chlorhexidine 0.12%).', 'icon': Icons.medication_rounded},
        {'title': 'Debridement', 'desc': 'Sub-marginal professional debridement with titanium-safe instruments.', 'icon': Icons.biotech_rounded},
      ];
    } else if (score >= 50) {
      return [
        {'title': 'Increased Surveillance', 'desc': 'Schedule next maintenance within 3 months to monitor soft tissue changes.', 'icon': Icons.schedule_rounded},
        {'title': 'Radiographic Tracking', 'desc': 'Compare current periapical radiographs with baseline to detect 1-2mm changes.', 'icon': Icons.screenshot_monitor_rounded},
        {'title': 'Hygiene Calibration', 'desc': 'Re-evaluate patient brushing technique and interdental cleaning compliance.', 'icon': Icons.cleaning_services_rounded},
      ];
    } else if (score >= 25) {
      return [
        {'title': 'Preventative Maintenance', 'desc': 'Continue regular 4-6 month professional cleanings.', 'icon': Icons.verified_user_rounded},
        {'title': 'Inflammation Monitoring', 'desc': 'Keep a close eye on bleeding on probing (BOP) at specific sites.', 'icon': Icons.remove_red_eye_rounded},
        {'title': 'Standard Protocol', 'desc': 'No immediate intervention required. Maintain current treatment plan.', 'icon': Icons.check_circle_rounded},
      ];
    } else {
      return [
        {'title': 'Standard Maintenance', 'desc': 'The implant is stable. Follow standard 6-month recall interval.', 'icon': Icons.verified_rounded},
        {'title': 'Routine Hygiene', 'desc': 'Patient oral hygiene is effective. Continue current home care regimen.', 'icon': Icons.thumb_up_rounded},
        {'title': 'Annual Imaging', 'desc': 'Standard annual radiographs are sufficient for monitoring bone levels.', 'icon': Icons.image_search_rounded},
      ];
    }
  }
}
