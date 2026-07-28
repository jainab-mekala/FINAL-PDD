import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/assessment_model.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class AddAssessmentScreen extends ConsumerStatefulWidget {
  final String implantId;
  const AddAssessmentScreen({super.key, required this.implantId});

  @override
  ConsumerState<AddAssessmentScreen> createState() => _AddAssessmentScreenState();
}

class _AddAssessmentScreenState extends ConsumerState<AddAssessmentScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  final _mbCtrl = TextEditingController(text: '3.0');
  final _bCtrl = TextEditingController(text: '3.0');
  final _dbCtrl = TextEditingController(text: '3.0');
  final _mlCtrl = TextEditingController(text: '3.0');
  final _lCtrl = TextEditingController(text: '3.0');
  final _dlCtrl = TextEditingController(text: '3.0');
  final _boneLevelCtrl = TextEditingController(text: '0.0');
  final _plaqueCtrl = TextEditingController(text: '20');
  final _notesCtrl = TextEditingController();

  bool _bop = false;
  bool _suppuration = false;
  bool _mucositis = false;
  bool _periImplantitis = false;
  MobilityGrade _mobility = MobilityGrade.none;
  bool _painReported = false;
  bool _swellingReported = false;
  bool _loosenessReported = false;
  int? _painScore;
  bool _isLoading = false;
  bool _runAIAfterSave = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [_mbCtrl, _bCtrl, _dbCtrl, _mlCtrl, _lCtrl, _dlCtrl, _boneLevelCtrl, _plaqueCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAssessment() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).asData?.value;
      if (user == null) return;

      final implant = await ref.read(patientServiceProvider).getImplant(widget.implantId);
      if (implant == null) return;

      final assessment = Assessment(
        id: const Uuid().v4(),
        implantId: widget.implantId,
        patientId: implant.patientId,
        doctorId: user.uid,
        assessmentDate: DateTime.now(),
        probingDepths: ProbingDepthMeasurement(
          mesialBuccal: double.tryParse(_mbCtrl.text) ?? 3.0,
          buccal: double.tryParse(_bCtrl.text) ?? 3.0,
          distalBuccal: double.tryParse(_dbCtrl.text) ?? 3.0,
          mesialLingual: double.tryParse(_mlCtrl.text) ?? 3.0,
          lingual: double.tryParse(_lCtrl.text) ?? 3.0,
          distalLingual: double.tryParse(_dlCtrl.text) ?? 3.0,
        ),
        boneLevelChange: double.tryParse(_boneLevelCtrl.text) ?? 0.0,
        bleedingOnProbing: _bop ? BleedingOnProbing.present : BleedingOnProbing.absent,
        suppuration: _suppuration ? Suppuration.present : Suppuration.absent,
        mobility: _mobility,
        plaqueScore: double.tryParse(_plaqueCtrl.text),
        mucositisPresent: _mucositis,
        periImplantitisDetected: _periImplantitis,
        patientReportedPain: _painReported,
        patientReportedSwelling: _swellingReported,
        patientReportedLooseness: _loosenessReported,
        painScore: _painScore,
        clinicalNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(patientServiceProvider).addAssessment(assessment);

      if (mounted) {
        if (_runAIAfterSave) {
          context.go('/ai-prediction/${widget.implantId}');
        } else {
          context.go('/implants/${widget.implantId}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e'), backgroundColor: const Color(0xFFFF4444)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              _buildTabBar(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProbingTab(),
                      _buildClinicalTab(),
                      _buildSymptomsTab(),
                    ],
                  ),
                ),
              ),
              _buildBottomAction(),
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
          IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
          const Spacer(),
          Text('SURVEILLANCE ENTRY', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: const Color(0xFF00F0FF), borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
        unselectedLabelColor: Colors.white24,
        labelColor: const Color(0xFF0D0720),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'PROBING'), Tab(text: 'CLINICAL'), Tab(text: 'SYMPTOMS')],
      ),
    );
  }

  Widget _buildProbingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('PROBING DEPTH (MM)'),
          const SizedBox(height: 16),
          _buildProbingCard('BUCCAL / FACIAL', [_mbCtrl, _bCtrl, _dbCtrl], ['MB', 'B', 'DB']),
          const SizedBox(height: 16),
          _buildProbingCard('LINGUAL / PALATAL', [_mlCtrl, _lCtrl, _dlCtrl], ['ML', 'L', 'DL']),
          const SizedBox(height: 32),
          _buildSectionLabel('RADIOGRAPHIC ANALYSIS'),
          const SizedBox(height: 16),
          _buildTextField(controller: _boneLevelCtrl, label: 'BONE LEVEL CHANGE', hint: '0.0', icon: Icons.show_chart_rounded, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField(controller: _plaqueCtrl, label: 'PLAQUE SCORE (%)', hint: '20', icon: Icons.biotech_rounded, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildProbingCard(String label, List<TextEditingController> ctrls, List<String> siteLabels) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(ctrls.length, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < ctrls.length - 1 ? 12 : 0),
                child: _ProbingField(ctrl: ctrls[i], label: siteLabels[i]),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('INFLAMMATORY INDICATORS'),
          const SizedBox(height: 16),
          _buildClinicalToggle('Bleeding on Probing', 'Capillary fragility at site', _bop, (v) => setState(() => _bop = v), const Color(0xFFFF6B35)),
          const SizedBox(height: 12),
          _buildClinicalToggle('Suppuration', 'Purulent exudate from sulcus', _suppuration, (v) => setState(() => _suppuration = v), const Color(0xFFFF4444)),
          const SizedBox(height: 12),
          _buildClinicalToggle('Peri-implant Mucositis', 'Soft tissue inflammation', _mucositis, (v) => setState(() => _mucositis = v), const Color(0xFFFFD700)),
          const SizedBox(height: 12),
          _buildClinicalToggle('Peri-implantitis', 'Confirmed radiographic bone loss', _periImplantitis, (v) => setState(() => _periImplantitis = v), const Color(0xFFFF4444)),
          const SizedBox(height: 32),
          _buildSectionLabel('STRUCTURAL STABILITY'),
          const SizedBox(height: 16),
          _buildMobilitySelector(),
          const SizedBox(height: 32),
          _buildSectionLabel('CLINICAL OBSERVATIONS'),
          const SizedBox(height: 16),
          _buildTextField(controller: _notesCtrl, label: 'SURVEILLANCE NOTES', hint: 'Enter detailed findings...', maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildSymptomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('PATIENT EXPERIENCE'),
          const SizedBox(height: 16),
          _buildClinicalToggle('Localized Pain', 'Patient reports chronic discomfort', _painReported, (v) => setState(() => _painReported = v), const Color(0xFFFF4444)),
          if (_painReported) ...[
            const SizedBox(height: 24),
            _buildPainSlider(),
          ],
          const SizedBox(height: 12),
          _buildClinicalToggle('Visual Swelling', 'Tissue edema or erythema', _swellingReported, (v) => setState(() => _swellingReported = v), const Color(0xFFFF6B35)),
          const SizedBox(height: 12),
          _buildClinicalToggle('Perceived Laxity', 'Sensation of hardware movement', _loosenessReported, (v) => setState(() => _loosenessReported = v), const Color(0xFFFFD700)),
          const SizedBox(height: 32),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            opacity: 0.1,
            color: const Color(0xFF00F0FF),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: Color(0xFF00F0FF), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'NEURAL RISK ENGINE WILL PROCESS THIS DATASET TO CALIBRATE SURVIVAL PROBABILITY.',
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF00F0FF), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      opacity: 0.1,
      borderRadius: 0,
      child: Column(
        children: [
          Row(
            children: [
              Switch(value: _runAIAfterSave, onChanged: (v) => setState(() => _runAIAfterSave = v), activeColor: const Color(0xFF00F0FF)),
              const SizedBox(width: 12),
              Text('TRIGGER AI ANALYSIS ON SAVE', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          GradientButton(text: 'COMMITT ASSESSMENT', onPressed: _isLoading ? null : _saveAssessment, isLoading: _isLoading, icon: Icons.terminal_rounded),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF00F0FF), letterSpacing: 2)),
        const SizedBox(width: 16),
        Expanded(child: Divider(color: const Color(0xFF00F0FF).withOpacity(0.1))),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, IconData? icon, TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 1))),
        GlassContainer(
          opacity: 0.05,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white10, fontSize: 14), prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.white24) : null, contentPadding: const EdgeInsets.all(16), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildClinicalToggle(String label, String subtitle, bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        opacity: value ? 0.1 : 0.03,
        color: value ? activeColor : Colors.transparent,
        border: Border.all(color: value ? activeColor.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: value ? activeColor : Colors.white12, width: 2), color: value ? activeColor : Colors.transparent),
              child: value ? const Icon(Icons.check, size: 12, color: Color(0xFF0D0720)) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: value ? Colors.white : Colors.white70)),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: value ? activeColor.withOpacity(0.7) : Colors.white24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilitySelector() {
    return Row(
      children: MobilityGrade.values.map((grade) {
        final isSelected = _mobility == grade;
        final label = grade == MobilityGrade.none ? 'NONE' : 'GR ${grade.index}';
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _mobility = grade),
            child: Container(
              margin: EdgeInsets.only(right: grade != MobilityGrade.grade3 ? 8 : 0),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 12),
                opacity: isSelected ? 0.1 : 0.03,
                color: isSelected ? const Color(0xFF00F0FF) : Colors.transparent,
                border: Border.all(color: isSelected ? const Color(0xFF00F0FF).withOpacity(0.3) : Colors.white.withOpacity(0.05)),
                child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? const Color(0xFF00F0FF) : Colors.white24, letterSpacing: 1)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPainSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAIN INTENSITY (VAS)', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 1)),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            activeTrackColor: const Color(0xFFFF4444),
            inactiveTrackColor: Colors.white10,
            thumbColor: const Color(0xFFFF4444),
            overlayColor: const Color(0xFFFF4444).withOpacity(0.2),
            valueIndicatorColor: const Color(0xFFFF4444),
            valueIndicatorTextStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800),
          ),
          child: Slider(
            value: (_painScore ?? 0).toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$_painScore',
            onChanged: (v) => setState(() => _painScore = v.toInt()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('NO PAIN', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white10)),
            Text('EXTREME', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white10)),
          ],
        ),
      ],
    );
  }
}

class _ProbingField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  const _ProbingField({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white24)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

