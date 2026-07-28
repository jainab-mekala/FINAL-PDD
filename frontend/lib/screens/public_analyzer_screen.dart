import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/risk_gauge_widget.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/report_storage_service.dart';


class PublicAnalyzerScreen extends StatefulWidget {
  const PublicAnalyzerScreen({super.key});
  @override
  State<PublicAnalyzerScreen> createState() => _PublicAnalyzerScreenState();
}

class _PublicAnalyzerScreenState extends State<PublicAnalyzerScreen> {
  final _pageCtrl = PageController();
  int _currentStep = 0; // 0=welcome, 1-7=steps, 8=result

  // Controllers
  final _ageCtrl = TextEditingController();
  final _hba1cCtrl = TextEditingController();
  final _diameterCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  // Values
  String _sex = 'Male';
  String _diabetes = 'No';
  String _historyPerio = 'No';
  String _maintenance = 'Regular';
  String _surface = 'Moderately Rough';
  String _prosthesis = 'Single Crown';
  String _cemented = 'No';
  String _platformSwitch = 'No';

  // Results
  double? _score;
  String? _riskLabel;
  String? _message;
  String? _error;
  bool _loading = false;

  static const _apiUrl = 'https://api-implant-developed-1.onrender.com/predict';
  static const _totalSteps = 7;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _ageCtrl.dispose();
    _hba1cCtrl.dispose();
    _diameterCtrl.dispose();
    _lengthCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  String _encodeSurface() {
    switch (_surface) {
      case 'Moderately Rough':
        return 'Moderately_rough';
      case 'Rough':
        return 'Rough';
      case 'Machined':
        return 'Machined';
      default:
        return 'Moderately_rough';
    }
  }

  String _encodeProsthesis() {
    switch (_prosthesis) {
      case 'Single Crown':
        return 'Single_crown';
      case 'Bridge':
        return 'Bridge';
      case 'Overdenture':
        return 'Overdenture';
      default:
        return 'Single_crown';
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  String? _validateCurrentStep() {
    switch (_currentStep) {
      case 1: // Patient Info: age required
        if (_ageCtrl.text.trim().isEmpty)
          return 'Please enter the patient\'s age.';
        break;
      case 2: // Medical History: hba1c required
        if (_hba1cCtrl.text.trim().isEmpty)
          return 'Please enter the HbA1c value.';
        break;
      case 4: // Implant Specs: diameter + length required
        if (_diameterCtrl.text.trim().isEmpty)
          return 'Please enter implant diameter.';
        if (_lengthCtrl.text.trim().isEmpty)
          return 'Please enter implant length.';
        break;
      case 6: // Duration: time required
        if (_timeCtrl.text.trim().isEmpty)
          return 'Please enter time in function.';
        break;
    }
    return null;
  }

  void _next() {
    final error = _validateCurrentStep();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFFF007A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
      return;
    }
    if (_currentStep < _totalSteps) {
      _goToStep(_currentStep + 1);
    } else {
      _calculate();
    }
  }

  void _back() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  Future<void> _calculate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _goToStep(_totalSteps + 1); // go to results page

    try {
      final body = {
        'age_years': double.tryParse(_ageCtrl.text) ?? 30.0,
        'sex': _sex == 'Male' ? 'M' : 'F',
        'diabetes': _diabetes,
        'hba1c_percent': double.tryParse(_hba1cCtrl.text) ?? 5.5,
        'history_periodontitis': _historyPerio,
        'maintenance_compliance': _maintenance,
        'implant_surface': _encodeSurface(),
        'implant_diameter_mm': double.tryParse(_diameterCtrl.text) ?? 3.75,
        'implant_length_mm': double.tryParse(_lengthCtrl.text) ?? 10.0,
        'prosthesis_type': _encodeProsthesis(),
        'cemented_restoration': _cemented,
        'platform_switching': _platformSwitch,
        'time_in_function_months': double.tryParse(_timeCtrl.text) ?? 12.0,
      };

      final effectiveUrl = _apiUrl;
      final res = await http
          .post(
            Uri.parse(effectiveUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final rawScore =
            (data['implantguard_risk_score'] as num?)?.toDouble() ?? 0.0;
        final finalScore = (rawScore / 100.0).clamp(0.0, 1.0);
        final finalLabel = data['risk_level']?.toString() ?? 'Unknown';
        if (mounted) {
          setState(() {
            _score = finalScore;
            _riskLabel = finalLabel;
            _message = data['message']?.toString();
          });
        }
        // Save to reports persistently across all history keys
        try {
          await ReportStorageService.saveReport({
            'date': DateTime.now().toIso8601String(),
            'score': finalScore,
            'condition': finalLabel,
            'age': _ageCtrl.text,
            'sex': _sex,
            'diabetes': _diabetes,
            'hba1c': _hba1cCtrl.text,
            'historyPerio': _historyPerio,
            'maintenance': _maintenance,
            'surface': _surface,
            'diameter': _diameterCtrl.text,
            'length': _lengthCtrl.text,
            'prosthesis': _prosthesis,
            'cemented': _cemented,
            'platformSwitch': _platformSwitch,
            'timeInFunction': _timeCtrl.text,
            'message': data['message']?.toString() ?? '',
          });
        } catch (_) {}

      } else {
        if (mounted) {
          String serverError = 'Server Error (${res.statusCode})';
          try {
            final errorData = jsonDecode(res.body);
            if (errorData is Map && errorData.containsKey('detail')) {
              serverError = errorData['detail'].toString();
            }
          } catch (_) {}
          setState(() => _error = serverError);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('TimeoutException')) {
          errorMsg =
              'The server is taking too long to respond. Render free tier may be waking up. Please try again in 30 seconds.';
        }
        setState(() => _error = errorMsg);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _riskColor(double score) {
    if (score >= 0.75) return const Color(0xFFDC2626);
    if (score >= 0.50) return const Color(0xFFE65100);
    if (score >= 0.25) return const Color(0xFFD97706);
    return const Color(0xFF388E3C);
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
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildWelcome(),
              _buildStepPage(1, 'Patient Info', Icons.person_outline_rounded,
                  [_fieldAge(), _fieldSex()]),
              _buildStepPage(
                  2,
                  'Medical History',
                  Icons.medical_services_outlined,
                  [_fieldDiabetes(), _fieldHba1c()]),
              _buildStepPage(3, 'Clinical History', Icons.history_rounded,
                  [_fieldPerio(), _fieldMaintenance()]),
              _buildStepPage(4, 'Implant Specs', Icons.settings_outlined,
                  [_fieldSurface(), _fieldDiameter(), _fieldLength()]),
              _buildStepPage(5, 'Prosthesis', Icons.build_circle_outlined, [
                _fieldProsthesis(),
                _fieldCemented(),
                _fieldPlatformSwitch()
              ]),
              _buildStepPage(
                  6, 'Duration', Icons.timer_outlined, [_fieldTime()]),
              _buildStepPage(7, 'Review & Predict', Icons.auto_awesome_rounded,
                  [_buildReviewSummary()]),
              _buildResultPage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  // ── WELCOME PAGE ──
  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFFD97757), Color(0xFFC15C3D)]),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFD97757).withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 4)
              ],
            ),
            child: const Icon(Icons.psychology_rounded,
                size: 50, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text('AI Risk Analyzer',
              style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF26231F))),
          const SizedBox(height: 12),
          Text(
            'Predict implant failure risk using\nour advanced machine learning model',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                fontSize: 15,
                color: const Color(0xFF6E6860),
                height: 1.5,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () => _goToStep(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97757),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                shadowColor: const Color(0x3DD97757),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 24),
                  const SizedBox(width: 8),
                  Text('START PREDICTING',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP PAGE WRAPPER ──
  Widget _buildStepPage(
      int step, String title, IconData icon, List<Widget> fields) {
    final isLast = step == _totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Color(0xFF6E6860), size: 20),
                  onPressed: _back),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: step / _totalSteps,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE8E2D9),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFD97757)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('$step/$_totalSteps',
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF6E6860),
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 24),
          // Title
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5ECE5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: const Color(0xFFD97757)),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF26231F))),
          const SizedBox(height: 24),
          // Fields
          Expanded(
            child: ListView(
              children: [
                ...fields.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 20), child: f)),
              ],
            ),
          ),
          // Next / Calculate button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLast ? const Color(0xFFC15C3D) : const Color(0xFFD97757),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                shadowColor: const Color(0x3DD97757),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'CALCULATE RISK' : 'NEXT',
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                      isLast
                          ? Icons.auto_awesome_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── RESULT PAGE ──
  Widget _buildResultPage() {
    if (_loading) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                  color: Color(0xFFD97757), strokeWidth: 3.5)),
          const SizedBox(height: 24),
          Text('Analyzing risk factors...',
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  color: const Color(0xFF6E6860),
                  fontWeight: FontWeight.w600)),
        ]),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline_rounded,
              size: 60, color: Color(0xFFDC2626)),
          const SizedBox(height: 16),
          Text('Something went wrong',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF26231F))),
          const SizedBox(height: 8),
          Text(_error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 14, color: const Color(0xFF6E6860))),
          const SizedBox(height: 32),
          ElevatedButton(
              onPressed: () => _goToStep(0), child: const Text('TRY AGAIN')),
        ]),
      );
    }
    if (_score == null) return const SizedBox.shrink();

    final color = _riskColor(_score!);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_awesome_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Text('AI PREDICTION RESULT',
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1)),
          ]),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8E2D9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF26231F).withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: [
            RiskGaugeWidget(riskScore: _score!, color: color),
            const SizedBox(height: 12),
            Text('${(_score! * 100).toStringAsFixed(1)}',
                style: GoogleFonts.outfit(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF26231F),
                    height: 1)),
            Text('/ 100  RISK SCORE',
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6E6860),
                    letterSpacing: 1)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30)),
              child: Text((_riskLabel ?? '').toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 1.5)),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: const Color(0xFF6E6860),
                      height: 1.5)),
            ],
          ]),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/suggestions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.12),
              foregroundColor: color,
              side: BorderSide(color: color, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 20),
                const SizedBox(width: 8),
                Text('VIEW CLINICAL SUGGESTIONS',
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _score = null;
                _riskLabel = null;
                _message = null;
                _error = null;
              });
              _goToStep(0);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD97757), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('NEW ANALYSIS',
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD97757),
                    letterSpacing: 1.2)),
          ),
        ),
      ]),
    );
  }

  // ── REVIEW SUMMARY ──
  Widget _buildReviewSummary() {
    final items = [
      ['Age', _ageCtrl.text.isEmpty ? '—' : '${_ageCtrl.text} years'],
      ['Sex', _sex],
      ['Diabetes', _diabetes],
      ['HbA1c', _hba1cCtrl.text.isEmpty ? '—' : '${_hba1cCtrl.text}%'],
      ['Perio History', _historyPerio],
      ['Maintenance', _maintenance],
      ['Surface', _surface],
      [
        'Diameter',
        _diameterCtrl.text.isEmpty ? '—' : '${_diameterCtrl.text} mm'
      ],
      ['Length', _lengthCtrl.text.isEmpty ? '—' : '${_lengthCtrl.text} mm'],
      ['Prosthesis', _prosthesis],
      ['Cemented', _cemented],
      ['Platform Switch', _platformSwitch],
      [
        'Time in Function',
        _timeCtrl.text.isEmpty ? '—' : '${_timeCtrl.text} months'
      ],
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E2D9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26231F).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: items
            .map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(i[0],
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: const Color(0xFF6E6860),
                                fontWeight: FontWeight.w500)),
                        Text(i[1],
                            style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF26231F))),
                      ]),
                ))
            .toList(),
      ),
    );
  }

  // ── FIELD BUILDERS ──
  Widget _fieldAge() => _inputField(
      _ageCtrl, 'Age (Years)', Icons.cake_outlined, TextInputType.number);
  Widget _fieldHba1c() => _inputField(
      _hba1cCtrl,
      'HbA1c %',
      Icons.bloodtype_outlined,
      const TextInputType.numberWithOptions(decimal: true));
  Widget _fieldDiameter() => _inputField(
      _diameterCtrl,
      'Diameter (mm)',
      Icons.radio_button_unchecked,
      const TextInputType.numberWithOptions(decimal: true));
  Widget _fieldLength() => _inputField(
      _lengthCtrl,
      'Length (mm)',
      Icons.straighten_outlined,
      const TextInputType.numberWithOptions(decimal: true));
  Widget _fieldTime() => _inputField(_timeCtrl, 'Time in Function (Months)',
      Icons.timer_outlined, TextInputType.number);

  Widget _fieldSex() => _optionSelector(
      'Sex',
      _sex,
      ['Male', 'Female'],
      [Icons.male_rounded, Icons.female_rounded],
      (v) => setState(() => _sex = v));
  Widget _fieldDiabetes() => _optionSelector(
      'Diabetes',
      _diabetes,
      ['Yes', 'No'],
      [Icons.check_circle_outline, Icons.warning_amber_rounded],
      (v) => setState(() => _diabetes = v));
  Widget _fieldPerio() => _optionSelector(
      'History of Perio',
      _historyPerio,
      ['Yes', 'No'],
      [Icons.check_circle_outline, Icons.warning_amber_rounded],
      (v) => setState(() => _historyPerio = v));
  Widget _fieldMaintenance() => _optionSelector(
      'Maintenance',
      _maintenance,
      ['Regular', 'Irregular'],
      [Icons.verified_outlined, Icons.schedule_rounded],
      (v) => setState(() => _maintenance = v));
  Widget _fieldCemented() => _optionSelector(
      'Cemented Restoration',
      _cemented,
      ['Yes', 'No'],
      [Icons.check_circle_outline, Icons.warning_amber_rounded],
      (v) => setState(() => _cemented = v));
  Widget _fieldPlatformSwitch() => _optionSelector(
      'Platform Switching',
      _platformSwitch,
      ['Yes', 'No'],
      [Icons.check_circle_outline, Icons.warning_amber_rounded],
      (v) => setState(() => _platformSwitch = v));

  Widget _fieldSurface() => _optionSelector(
      'Surface Type',
      _surface,
      ['Machined', 'Moderately Rough', 'Rough'],
      [Icons.lens_outlined, Icons.texture_rounded, Icons.grain_rounded],
      (v) => setState(() => _surface = v));
  Widget _fieldProsthesis() => _optionSelector(
      'Prosthesis Type',
      _prosthesis,
      ['Single Crown', 'Bridge', 'Overdenture'],
      [
        Icons.looks_one_rounded,
        Icons.account_balance_outlined,
        Icons.auto_awesome_mosaic_outlined
      ],
      (v) => setState(() => _prosthesis = v));

  // ── REUSABLE INPUT FIELD ──
  Widget _inputField(TextEditingController ctrl, String label, IconData icon,
      TextInputType type) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E2D9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26231F).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: const Color(0xFFD97757)),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6E6860))),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF26231F)),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFA39C93)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ]),
    );
  }

  // ── REUSABLE OPTION SELECTOR ──
  Widget _optionSelector(String label, String current, List<String> options,
      List<IconData> icons, ValueChanged<String> onSelect) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6E6860),
              letterSpacing: 1.2)),
      const SizedBox(height: 10),
      Row(
        children: List.generate(options.length, (i) {
          final opt = options[i];
          final selected = current == opt;

          Color activeColor = const Color(0xFFD97757); // Claude Terracotta
          if (opt == 'Yes')
            activeColor = const Color(0xFF388E3C); // Success Green
          if (opt == 'No') activeColor = const Color(0xFFDC2626); // Error Red

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < options.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () => onSelect(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color:
                        selected ? activeColor.withOpacity(0.12) : Colors.white,
                    border: Border.all(
                        color: selected ? activeColor : const Color(0xFFE8E2D9),
                        width: selected ? 1.8 : 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF26231F).withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icons[i],
                        size: 24,
                        color:
                            selected ? activeColor : const Color(0xFFA39C93)),
                    const SizedBox(height: 8),
                    Text(opt,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                            color: selected
                                ? activeColor
                                : const Color(0xFF6E6860))),
                  ]),
                ),
              ),
            ),
          );
        }),
      ),
    ]);
  }
}
