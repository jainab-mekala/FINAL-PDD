import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/implant_model.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';

class AddImplantScreen extends ConsumerStatefulWidget {
  final String patientId;
  const AddImplantScreen({super.key, required this.patientId});

  @override
  ConsumerState<AddImplantScreen> createState() => _AddImplantScreenState();
}

class _AddImplantScreenState extends ConsumerState<AddImplantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _diameterCtrl = TextEditingController(text: '3.5');
  final _lengthCtrl = TextEditingController(text: '10.0');
  final _notesCtrl = TextEditingController();

  String? _patientId;
  DateTime _placementDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime? _loadingDate;
  int _toothNumber = 16;
  String _arch = 'upper';
  String _side = 'right';
  bool _hadComplications = false;
  String? _boneGraftType;
  bool _isLoading = false;

  final List<String> _commonBrands = [
    'Nobel Biocare', 'Straumann', 'Dentsply Sirona', 'Zimmer Biomet',
    'BioHorizons', 'Osstem', 'MegaGen', 'Neodent', 'Other',
  ];
  String _selectedBrand = 'Nobel Biocare';

  final List<int> _commonToothNumbers = [
    14, 15, 16, 17, 24, 25, 26, 27, 34, 35, 36, 37, 44, 45, 46, 47, 11, 21, 12, 22, 31, 41,
  ];

  @override
  void initState() {
    super.initState();
    _patientId = widget.patientId;
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _diameterCtrl.dispose();
    _lengthCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveImplant() async {
    if (!_formKey.currentState!.validate()) return;
    if (_patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient ID missing')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).asData?.value;
      if (user == null) return;

      final implant = Implant(
        id: const Uuid().v4(),
        patientId: _patientId!,
        doctorId: user.uid,
        brand: _selectedBrand == 'Other' ? _brandCtrl.text.trim() : _selectedBrand,
        model: _modelCtrl.text.trim(),
        diameter: double.tryParse(_diameterCtrl.text) ?? 3.5,
        length: double.tryParse(_lengthCtrl.text) ?? 10.0,
        position: ImplantPosition(arch: _arch, side: _side, toothNumber: _toothNumber),
        placementDate: _placementDate,
        loadingDate: _loadingDate,
        boneGraftType: _boneGraftType,
        hadComplicationsAtPlacement: _hadComplications,
        complicationNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        currentStatus: ImplantStatus.healthy,
        riskScore: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        assessmentIds: [],
      );

      await ref.read(patientServiceProvider).addImplant(implant);
      if (mounted) context.go('/patients/$_patientId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFFF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
              _buildHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('HARDWARE SPECIFICATIONS'),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'IMPLANT BRAND',
                          value: _selectedBrand,
                          items: _commonBrands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                          onChanged: (v) => setState(() => _selectedBrand = v!),
                        ),
                        if (_selectedBrand == 'Other') ...[
                          const SizedBox(height: 16),
                          _buildTextField(controller: _brandCtrl, label: 'CUSTOM BRAND NAME', hint: 'Enter manufacturer'),
                        ],
                        const SizedBox(height: 16),
                        _buildTextField(controller: _modelCtrl, label: 'MODEL / SYSTEM', hint: 'e.g. NobelActive, BLX', icon: Icons.precision_manufacturing_rounded),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _diameterCtrl, label: 'DIAMETER (MM)', hint: '3.5', keyboardType: TextInputType.number)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(controller: _lengthCtrl, label: 'LENGTH (MM)', hint: '10.0', keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildSectionLabel('ANATOMICAL POSITION'),
                        const SizedBox(height: 16),
                        _buildSegmentSelector(label: 'ARCH', options: ['upper', 'lower'], labels: ['UPPER', 'LOWER'], selected: _arch, onChanged: (v) => setState(() => _arch = v)),
                        const SizedBox(height: 16),
                        _buildSegmentSelector(label: 'SIDE', options: ['left', 'right'], labels: ['LEFT', 'RIGHT'], selected: _side, onChanged: (v) => setState(() => _side = v)),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'TOOTH NUMBER (FDI)',
                          value: _commonToothNumbers.contains(_toothNumber) ? _toothNumber : _commonToothNumbers.first,
                          items: _commonToothNumbers.map((n) => DropdownMenuItem(value: n, child: Text('Tooth #$n'))).toList(),
                          onChanged: (v) => setState(() => _toothNumber = v as int),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionLabel('SURGICAL TIMELINE'),
                        const SizedBox(height: 16),
                        _buildDatePicker(label: 'PLACEMENT DATE', value: _placementDate, onPicked: (d) => setState(() => _placementDate = d)),
                        const SizedBox(height: 16),
                        _buildDatePicker(label: 'LOADING DATE (OPTIONAL)', value: _loadingDate, onPicked: (d) => setState(() => _loadingDate = d), isOptional: true),
                        const SizedBox(height: 32),
                        _buildSectionLabel('SURGICAL PARAMETERS'),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'BONE GRAFT PROTOCOL',
                          value: _boneGraftType,
                          items: const [
                            DropdownMenuItem(value: null, child: Text('NONE')),
                            DropdownMenuItem(value: 'autograft', child: Text('AUTOGRAFT')),
                            DropdownMenuItem(value: 'allograft', child: Text('ALLOGRAFT')),
                            DropdownMenuItem(value: 'xenograft', child: Text('XENOGRAFT')),
                            DropdownMenuItem(value: 'alloplast', child: Text('ALLOPLAST')),
                          ],
                          onChanged: (v) => setState(() => _boneGraftType = v as String?),
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchTile(
                          label: 'Placement Complications',
                          subtitle: 'Primary stability issues or dehiscence',
                          value: _hadComplications,
                          onChanged: (v) => setState(() => _hadComplications = v),
                        ),
                        if (_hadComplications) ...[
                          const SizedBox(height: 16),
                          _buildTextField(controller: _notesCtrl, label: 'COMPLICATION LOG', hint: 'Describe clinical anomalies...', maxLines: 3),
                        ],
                        const SizedBox(height: 40),
                        GradientButton(text: 'INITIALIZE IMPLANT', onPressed: _isLoading ? null : _saveImplant, isLoading: _isLoading, icon: Icons.settings_input_component_rounded),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
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
          IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20), onPressed: () => Navigator.pop(context)),
          const Spacer(),
          Text('NEW IMPLANT SURVEILLANCE', style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF0284C7), letterSpacing: 1.5)),
        const SizedBox(width: 16),
        Expanded(child: Divider(color: const Color(0xFF0284C7).withOpacity(0.2))),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, IconData? icon, TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1))),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 14), prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF0284C7)) : null, contentPadding: const EdgeInsets.all(16), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required dynamic value, required List<DropdownMenuItem<dynamic>> items, required ValueChanged<dynamic> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1))),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<dynamic>(
            value: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16), border: InputBorder.none),
            icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({required String label, required DateTime? value, required ValueChanged<DateTime> onPicked, bool isOptional = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1))),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: value ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF0284C7)),
                const SizedBox(width: 12),
                Text(value != null ? DateFormat('MMMM d, yyyy').format(value) : 'NOT SET', style: GoogleFonts.plusJakartaSans(color: value != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentSelector({required String label, required List<String> options, required List<String> labels, required String selected, required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1))),
        Row(
          children: List.generate(options.length, (i) {
            final isSelected = options[i] == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(options[i]),
                child: Container(
                  margin: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(labels[i], textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B), letterSpacing: 1)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({required String label, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.outfit(color: const Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w700)), Text(subtitle, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 12))])),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFEA580C)),
        ],
      ),
    );
  }
}

