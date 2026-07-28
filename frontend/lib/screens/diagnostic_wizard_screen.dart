import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/prediction_result.dart';
import '../widgets/gradient_button.dart';
import '../services/report_storage_service.dart';


class DiagnosticWizardScreen extends StatefulWidget {
  const DiagnosticWizardScreen({super.key});

  @override
  State<DiagnosticWizardScreen> createState() => _DiagnosticWizardScreenState();
}

class _DiagnosticWizardScreenState extends State<DiagnosticWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Wizard Data
  int _age = 45;
  bool _isDiabetic = false;
  bool _isSmoker = false;
  bool _hasPerioHistory = false;
  double _maxProbingDepth = 3.0;
  double _boneLevelChange = 0.5;
  bool _bleedingOnProbing = false;
  bool _suppuration = false;
  int _mobilityGrade = 0;
  double _plaqueScore = 20.0;

  final int _totalSteps = 10;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _calculateAndShowResult();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _calculateAndShowResult() {
    // Simplified Risk Calculation Logic
    double score = 0.1;
    if (_age > 60) score += 0.1;
    if (_isDiabetic) score += 0.15;
    if (_isSmoker) score += 0.2;
    if (_hasPerioHistory) score += 0.1;

    // Clinical factors weighted more heavily
    score += (_maxProbingDepth - 3).clamp(0, 5) * 0.1;
    score += _boneLevelChange.clamp(0, 5) * 0.12;

    if (_bleedingOnProbing) score += 0.08;
    if (_suppuration) score += 0.15;
    if (_mobilityGrade > 0) score += 0.1 * _mobilityGrade;
    if (_plaqueScore > 40) score += 0.05;

    final finalScore = (score * 10).clamp(0.0, 10.0);
    String level = "Low Risk";
    String message =
        "All parameters are within normal physiological limits. Continue routine 6-month maintenance.";

    if (finalScore >= 7.5) {
      level = "Critical Risk";
      message =
          "Urgent clinical intervention required. Radiographic bone loss and inflammatory markers indicate active peri-implantitis.";
    } else if (finalScore >= 5.0) {
      level = "High Risk";
      message =
          "Signs of peri-implant disease detected. Professional debridement and enhanced oral hygiene protocols are recommended.";
    } else if (finalScore >= 2.5) {
      level = "Moderate Risk";
      message =
          "Localized inflammation present. Monitor closely and reduce recall interval to 3-4 months.";
    }

    final normalizedScore = (finalScore / 10.0).clamp(0.0, 1.0);

    // Save to reports persistent history
    ReportStorageService.saveReport({
      'date': DateTime.now().toIso8601String(),
      'score': normalizedScore,
      'condition': level,
      'age': _age.toString(),
      'diabetes': _isDiabetic ? 'Yes' : 'No',
      'historyPerio': _hasPerioHistory ? 'Yes' : 'No',
      'message': message,
      'probingDepth': _maxProbingDepth,
      'boneLevelChange': _boneLevelChange,
      'bleeding': _bleedingOnProbing ? 'Yes' : 'No',
    });

    final result = PredictionResult(
      score: double.parse(finalScore.toStringAsFixed(1)),
      riskLevel: level,
      message: message,
    );

    context.push('/result', extra: result);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    _buildStep(
                      title: "Patient Age",
                      description:
                          "Age is a fundamental risk factor. Older patients may show reduced healing capacity and higher cumulative systemic risk.",
                      content: _buildSliderStep(
                        value: _age.toDouble(),
                        min: 18,
                        max: 95,
                        label: "$_age Years",
                        onChanged: (v) => setState(() => _age = v.toInt()),
                      ),
                    ),
                    _buildStep(
                      title: "Diabetes Status",
                      description:
                          "Uncontrolled diabetes significantly impairs microvascular circulation and soft tissue integration around the implant.",
                      content: _buildToggleStep(
                        value: _isDiabetic,
                        onChanged: (v) => setState(() => _isDiabetic = v),
                        label: _isDiabetic ? "DIABETIC" : "NON-DIABETIC",
                        icon: Icons.bloodtype_rounded,
                      ),
                    ),
                    _buildStep(
                      title: "Smoking Profile",
                      description:
                          "Smoking increases peri-implantitis risk by up to 3.6x. It restricts blood flow and alters the immune response in the peri-implant sulcus.",
                      content: _buildToggleStep(
                        value: _isSmoker,
                        onChanged: (v) => setState(() => _isSmoker = v),
                        label: _isSmoker ? "CURRENT SMOKER" : "NON-SMOKER",
                        icon: Icons.smoking_rooms_rounded,
                      ),
                    ),
                    _buildStep(
                      title: "Periodontal History",
                      description:
                          "A history of periodontitis is a strong predictor of future peri-implant bone loss due to similar microbial susceptibility.",
                      content: _buildToggleStep(
                        value: _hasPerioHistory,
                        onChanged: (v) => setState(() => _hasPerioHistory = v),
                        label:
                            _hasPerioHistory ? "HISTORY PRESENT" : "NO HISTORY",
                        icon: Icons.history_rounded,
                      ),
                    ),
                    _buildStep(
                      title: "Max Probing Depth",
                      description:
                          "The deepest point measured around the implant. Depths >5mm often indicate pocket formation and active disease.",
                      content: _buildSliderStep(
                        value: _maxProbingDepth,
                        min: 1.0,
                        max: 12.0,
                        label: "${_maxProbingDepth.toStringAsFixed(1)} mm",
                        onChanged: (v) => setState(() => _maxProbingDepth = v),
                      ),
                    ),
                    _buildStep(
                      title: "Bone Level Change",
                      description:
                          "Radiographic bone loss over time. Any loss >2mm from the initial baseline is a hallmark of peri-implantitis.",
                      content: _buildSliderStep(
                        value: _boneLevelChange,
                        min: 0.0,
                        max: 8.0,
                        label: "${_boneLevelChange.toStringAsFixed(1)} mm",
                        onChanged: (v) => setState(() => _boneLevelChange = v),
                      ),
                    ),
                    _buildStep(
                      title: "Bleeding on Probing",
                      description:
                          "BOP is a primary indicator of soft tissue inflammation. Consistent bleeding suggests capillary fragility in the sulcus.",
                      content: _buildToggleStep(
                        value: _bleedingOnProbing,
                        onChanged: (v) =>
                            setState(() => _bleedingOnProbing = v),
                        label:
                            _bleedingOnProbing ? "BOP PRESENT" : "NO BLEEDING",
                        icon: Icons.water_drop_rounded,
                      ),
                    ),
                    _buildStep(
                      title: "Suppuration",
                      description:
                          "The presence of pus (exudate) is a critical indicator of acute infection and rapid bone destruction.",
                      content: _buildToggleStep(
                        value: _suppuration,
                        onChanged: (v) => setState(() => _suppuration = v),
                        label: _suppuration ? "SUPPURATING" : "NORMAL SULCUS",
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                    _buildStep(
                      title: "Mobility Grade",
                      description:
                          "Hardware movement. Any grade of mobility in a previously integrated osseointegrated implant indicates failure.",
                      content: _buildMobilityStep(),
                    ),
                    _buildStep(
                      title: "Plaque Score",
                      description:
                          "Oral hygiene efficacy. High plaque accumulation is the primary etiology for peri-implant mucositis.",
                      content: _buildSliderStep(
                        value: _plaqueScore,
                        min: 0.0,
                        max: 100.0,
                        label: "${_plaqueScore.toInt()}% Coverage",
                        onChanged: (v) => setState(() => _plaqueScore = v),
                      ),
                    ),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DIAGNOSTIC PROTOCOL",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF6E6860),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "${_currentStep + 1} / $_totalSteps",
                style: GoogleFonts.outfit(
                  color: const Color(0xFFD97757),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: const Color(0xFFE8E2D9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD97757)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
      {required String title,
      required String description,
      required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF26231F),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: Color(0xFFD97757)),
                    const SizedBox(width: 8),
                    Text(
                      "CLINICAL CONTEXT",
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD97757),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF6E6860),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          content,
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildSliderStep({
    required double value,
    required double min,
    required double max,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFD97757),
          ),
        ),
        const SizedBox(height: 20),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: const Color(0xFFD97757),
            inactiveTrackColor: const Color(0xFFE8E2D9),
            thumbColor: const Color(0xFFD97757),
            overlayColor: const Color(0xFFD97757).withOpacity(0.2),
            valueIndicatorColor: const Color(0xFFD97757),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleStep({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFF5ECE5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? const Color(0xFFD97757) : const Color(0xFFE8E2D9),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26231F).withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 32,
                color:
                    value ? const Color(0xFFD97757) : const Color(0xFFA39C93)),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color:
                    value ? const Color(0xFFD97757) : const Color(0xFF6E6860),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilityStep() {
    return Row(
      children: List.generate(4, (i) {
        final isSelected = _mobilityGrade == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _mobilityGrade = i),
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFEE2E2) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFE8E2D9),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF26231F).withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "$i",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF6E6860),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "GRADE",
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFA39C93),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  "BACK",
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GradientButton(
              text: _currentStep == _totalSteps - 1
                  ? "FINALIZE ANALYSIS"
                  : "CONTINUE",
              onPressed: _nextStep,
              icon: _currentStep == _totalSteps - 1
                  ? Icons.analytics_rounded
                  : Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
