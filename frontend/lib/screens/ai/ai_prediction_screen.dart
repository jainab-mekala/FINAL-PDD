import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/prediction_model.dart';
import '../../models/implant_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../services/report_storage_service.dart';


class AIPredictionScreen extends ConsumerStatefulWidget {
  final String implantId;
  const AIPredictionScreen({super.key, required this.implantId});

  @override
  ConsumerState<AIPredictionScreen> createState() => _AIPredictionScreenState();
}

class _AIPredictionScreenState extends ConsumerState<AIPredictionScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  PredictionResult? _result;
  late AnimationController _pulseController;
  late AnimationController _resultController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _resultOpacity;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _resultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _runAnalysis());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    setState(() => _isAnalyzing = true);

    try {
      final implant = await ref.read(patientServiceProvider).getImplant(widget.implantId);
      if (implant == null) return;

      final patient = await ref.read(patientServiceProvider).getPatient(implant.patientId);
      if (patient == null) return;

      final assessments = await ref.read(patientServiceProvider).getAssessmentHistory(widget.implantId);

      final result = await ref.read(aiServiceProvider).predict(
        patient: patient,
        implant: implant,
        assessmentHistory: assessments,
      );

      final status = _riskToStatus(result.riskLevel);
      await ref.read(patientServiceProvider).updateImplantStatus(
        widget.implantId,
        status,
        result.riskScore,
      );

      if (assessments.isNotEmpty) {
        await ref.read(patientServiceProvider).updateAssessmentWithAIPrediction(
          assessments.first.id,
          result.riskScore,
          result.riskLabel,
          result.primaryRiskFactors,
          result.featureContributions,
        );
      }

      // Save to reports persistent history across all keys
      try {
        await ReportStorageService.saveReport({
          'date': DateTime.now().toIso8601String(),
          'score': result.riskScore,
          'condition': result.riskLabel,
          'age': patient.age.toString(),
          'sex': patient.gender.name,
          'diabetes': patient.medicalConditions.contains('diabetes') ? 'Yes' : 'No',
          'hba1c': 'N/A',
          'historyPerio': patient.hasPeriodontalHistory ? 'Yes' : 'No',
          'maintenance': 'N/A',
          'surface': implant.brand,
          'diameter': implant.diameter.toString(),
          'length': implant.length.toString(),
          'prosthesis': implant.model,
          'message': result.explanation,
        });
      } catch (_) {}

      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
      _resultController.forward();
    } catch (e) {
      setState(() => _isAnalyzing = false);
    }
  }

  ImplantStatus _riskToStatus(RiskLevel level) {
    switch (level) {
      case RiskLevel.low: return ImplantStatus.healthy;
      case RiskLevel.moderate: return ImplantStatus.watchlist;
      case RiskLevel.high: return ImplantStatus.atRisk;
      case RiskLevel.critical: return ImplantStatus.critical;
    }
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low: return const Color(0xFF00FF9F);
      case RiskLevel.moderate: return const Color(0xFFFFD700);
      case RiskLevel.high: return const Color(0xFFFF6B35);
      case RiskLevel.critical: return const Color(0xFFFF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0720),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0720), Color(0xFF1A0D3A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isAnalyzing ? _buildAnalyzingView() : _buildResultView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'NEURAL ANALYSIS',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 180 * _pulseAnimation.value,
                    height: 180 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.1), width: 1),
                    ),
                  );
                },
              ),
              GlassContainer(
                width: 140,
                height: 140,
                borderRadius: 70,
                opacity: 0.1,
                border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3), width: 2),
                child: const Center(
                  child: Icon(Icons.psychology_rounded, size: 60, color: Color(0xFF00F0FF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text(
            'PROCESSING BIOMETRICS',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00F0FF),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Running multi-factor clinical simulation...',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
                minHeight: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_result == null) {
      return Center(
        child: GradientButton(
          text: 'INITIATE ANALYSIS',
          onPressed: _runAnalysis,
          icon: Icons.play_arrow_rounded,
        ),
      );
    }

    final result = _result!;
    final riskColor = _getRiskColor(result.riskLevel);

    return FadeTransition(
      opacity: _resultOpacity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(32),
              opacity: 0.05,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: result.riskScore,
                          strokeWidth: 4,
                          backgroundColor: riskColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${(result.riskScore * 100).toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          Text(
                            'RISK SCORE',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: riskColor, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(30), border: Border.all(color: riskColor.withOpacity(0.2))),
                    child: Text(
                      result.riskLabel.toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: riskColor, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    result.explanation,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withOpacity(0.6), height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('RISK VECTOR BREAKDOWN'),
            const SizedBox(height: 16),
            ...() {
              final sorted = result.featureContributions.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
              return sorted.map((entry) => _FeatureContributionBar(label: entry.key, value: entry.value, color: riskColor));
            }(),
            const SizedBox(height: 32),
            _buildSectionHeader('CLINICAL PROTOCOLS'),
            const SizedBox(height: 16),
            ...result.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                opacity: 0.03,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF00F0FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00F0FF), size: 18),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.title,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec.description,
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 40),
            GradientButton(text: 'EXPORT DIAGNOSTIC', onPressed: () {}, icon: Icons.ios_share_rounded),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 2),
        ),
        const SizedBox(width: 16),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
      ],
    );
  }
}

class _FeatureContributionBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _FeatureContributionBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 1)),
              const Spacer(),
              Text('${(value * 100).toStringAsFixed(0)}%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withOpacity(0.03),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

