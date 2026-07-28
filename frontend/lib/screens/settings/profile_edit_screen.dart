import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:implantguard_ai/providers/auth_provider.dart';
import 'package:implantguard_ai/services/auth_service.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentUserProfileProvider).asData?.value;
      if (profile != null) {
        _firstNameCtrl.text = profile.firstName;
        _lastNameCtrl.text = profile.lastName;
        _phoneCtrl.text = profile.phone;
      }
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final currentProfile = ref.read(currentUserProfileProvider).asData?.value;
      if (currentProfile != null) {
        final updatedProfile = UserProfile(
          uid: currentProfile.uid,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          email: currentProfile.email,
          phone: _phoneCtrl.text.trim(),
        );
        await ref.read(authServiceProvider).updateProfile(updatedProfile);
        ref.invalidate(currentUserProfileProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully!',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF388E3C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatarSection(),
                        const SizedBox(height: 32),
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
                              'PERSONAL INFORMATION',
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
                        _buildTextField(
                          controller: _firstNameCtrl,
                          label: 'First Name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _lastNameCtrl,
                          label: 'Last Name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _phoneCtrl,
                          label: 'Emergency Mobile',
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97757),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFD97757).withOpacity(0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'SAVE CHANGES',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF26231F), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCOUNT',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97757),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Edit Profile',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF26231F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final initial = profile?.firstName.isNotEmpty == true
        ? profile!.firstName[0].toUpperCase()
        : 'U';

    return Center(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFF5ECE5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD97757).withOpacity(0.3), width: 3),
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFD97757),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile?.email ?? '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF6E6860),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E2D9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26231F).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF26231F),
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF6E6860),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFFD97757)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD97757), width: 1.5),
          ),
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}
