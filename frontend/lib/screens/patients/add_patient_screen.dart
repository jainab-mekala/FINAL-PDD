import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/patient_model.dart';
import '../../widgets/gradient_button.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bmiCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _dob = DateTime(1980, 1, 1);
  Gender _gender = Gender.male;
  SmokingStatus _smoking = SmokingStatus.nonSmoker;
  bool _perioHistory = false;
  bool _isLoading = false;

  final List<String> _selectedConditions = [];
  final List<String> _commonConditions = [
    'Diabetes (Type 1)',
    'Diabetes (Type 2)',
    'Osteoporosis',
    'Hypertension',
    'Cardiovascular Disease',
    'Immunosuppression',
    'Bisphosphonate Therapy',
    'Radiation Therapy',
    'Sjögren\'s Syndrome',
    'Rheumatoid Arthritis',
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bmiCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).asData?.value;
      if (user == null) return;

      final patient = Patient(
        id: const Uuid().v4(),
        doctorId: user.uid,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        dateOfBirth: _dob,
        gender: _gender,
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        smokingStatus: _smoking,
        medicalConditions: _selectedConditions,
        medications: [],
        bmi: _bmiCtrl.text.isEmpty ? null : double.tryParse(_bmiCtrl.text),
        hasPeriodontalHistory: _perioHistory,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        implantIds: [],
      );

      final id = await ref.read(patientServiceProvider).addPatient(patient);
      if (mounted) context.go('/patients/$id');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: const Color(0xFFFF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00F0FF), surface: Color(0xFF1A0D3A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('PERSONAL IDENTITY'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameCtrl,
                                label: 'FIRST NAME',
                                hint: 'John',
                                icon: Icons.person_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameCtrl,
                                label: 'LAST NAME',
                                hint: 'Doe',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDatePicker(),
                        const SizedBox(height: 16),
                        _buildGenderSelector(),
                        const SizedBox(height: 32),
                        _buildSectionLabel('CONTACT PROTOCOLS'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailCtrl,
                          label: 'EMAIL ADDRESS',
                          hint: 'patient@clinical.com',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneCtrl,
                          label: 'SECURE PHONE',
                          hint: '+1 (555) 000-0000',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 32),
                        _buildSectionLabel('CLINICAL BIOMETRICS'),
                        const SizedBox(height: 16),
                        _buildSmokingSelector(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _bmiCtrl,
                          label: 'BODY MASS INDEX',
                          hint: '24.5',
                          icon: Icons.monitor_weight_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchTile(
                          label: 'Periodontal History',
                          subtitle: 'History of chronic bone loss',
                          value: _perioHistory,
                          onChanged: (v) => setState(() => _perioHistory = v),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionLabel('MEDICAL CONDITIONS'),
                        const SizedBox(height: 16),
                        _buildConditionsWrap(),
                        const SizedBox(height: 32),
                        _buildSectionLabel('INTERNAL NOTES'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _notesCtrl,
                          label: 'CLINICAL OBSERVATIONS',
                          hint:
                              'Enter relevant surgical or anatomical notes...',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 40),
                        GradientButton(
                          text: 'INITIALIZE PATIENT',
                          onPressed: _isLoading ? null : _savePatient,
                          isLoading: _isLoading,
                          icon: Icons.person_add_alt_1_rounded,
                        ),
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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A), size: 20),
            onPressed: () => context.go('/patients'),
          ),
          const Spacer(),
          Text(
            'NEW CLINICAL ENTRY',
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
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0284C7),
              letterSpacing: 1.5),
        ),
        const SizedBox(width: 16),
        Expanded(
            child: Divider(color: const Color(0xFF0284C7).withOpacity(0.2))),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 1),
          ),
        ),
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
            style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: icon != null
                  ? Icon(icon, size: 18, color: const Color(0xFF0284C7))
                  : null,
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'DATE OF BIRTH',
            style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 1),
          ),
        ),
        GestureDetector(
          onTap: _pickDOB,
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
                const Icon(Icons.cake_rounded,
                    size: 18, color: Color(0xFF0284C7)),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMMM d, yyyy').format(_dob),
                  style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.expand_more_rounded,
                    size: 18, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'BIOLOGICAL GENDER',
            style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 1),
          ),
        ),
        Row(
          children: [
            _buildGenderOption(Gender.male, 'MALE'),
            const SizedBox(width: 8),
            _buildGenderOption(Gender.female, 'FEMALE'),
            const SizedBox(width: 8),
            _buildGenderOption(Gender.other, 'OTHER'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(Gender gender, String label) {
    final isSelected = _gender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF64748B),
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmokingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'SMOKING PROFILE',
            style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 1),
          ),
        ),
        Row(
          children: [
            _buildSmokingOption(SmokingStatus.nonSmoker, 'NON-SMOKER'),
            const SizedBox(width: 8),
            _buildSmokingOption(SmokingStatus.formerSmoker, 'FORMER'),
            const SizedBox(width: 8),
            _buildSmokingOption(SmokingStatus.currentSmoker, 'CURRENT'),
          ],
        ),
      ],
    );
  }

  Widget _buildSmokingOption(SmokingStatus status, String label) {
    final isSelected = _smoking == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _smoking = status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFEF3C7) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFFD97706)
                    : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? const Color(0xFFD97706)
                  : const Color(0xFF64748B),
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      {required String label,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged}) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0284C7),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonConditions.map((condition) {
        final isSelected = _selectedConditions.contains(condition);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedConditions.remove(condition);
              } else {
                _selectedConditions.add(condition);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0284C7)
                      : const Color(0xFFE2E8F0)),
            ),
            child: Text(
              condition,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
