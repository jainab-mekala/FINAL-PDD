import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // OTP State
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailCtrl.text.isEmpty || !_emailCtrl.text.contains('@')) {
      setState(() => _errorMessage = 'PLEASE ENTER A VALID CLINICAL EMAIL');
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).sendOtp(_emailCtrl.text.trim());
      setState(() => _isOtpSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('VERIFICATION CODE SENT TO YOUR EMAIL')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'FAILED TO SEND VERIFICATION CODE');
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length < 6) {
      setState(() => _errorMessage = 'ENTER THE 6-DIGIT VERIFICATION CODE');
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(authServiceProvider).verifyOtp(
        _emailCtrl.text.trim(),
        _otpCtrl.text.trim(),
      );

      if (success) {
        setState(() => _isOtpVerified = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('EMAIL VERIFIED SUCCESSFULLY')),
          );
        }
      } else {
        setState(() => _errorMessage = 'INVALID VERIFICATION CODE');
      }
    } catch (e) {
      setState(() => _errorMessage = 'VERIFICATION PROTOCOL ERROR');
    } finally {
      setState(() => _isVerifyingOtp = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() {
        _errorMessage = _parseError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(String error) {
    if (error.contains('email-already-in-use')) return 'Credential conflict: Email exists';
    if (error.contains('weak-password')) return 'Security failure: Weak key';
    if (error.contains('network')) return 'Transmission link failure';
    return 'Registration protocol error';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF64748B), size: 20),
                    onPressed: () => context.go('/auth/login'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SYSTEM ENROLLMENT',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0284C7),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NEW CLINICAL USER',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_errorMessage != null) ...[
                    _buildErrorBanner(),
                    const SizedBox(height: 24),
                  ],

                  _sectionLabel('Access Configuration'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _emailCtrl,
                          label: 'System Email',
                          hint: 'clinical@implantguard.ai',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          enabled: !_isOtpSent,
                          validator: (v) => (v == null || !v.contains('@')) ? 'Invalid' : null,
                          suffixIcon: _isOtpSent && !_isOtpVerified
                              ? TextButton(
                                  onPressed: () => setState(() {
                                    _isOtpSent = false;
                                    _otpCtrl.clear();
                                  }),
                                  child: Text('CHANGE', style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF0284C7), fontWeight: FontWeight.w800)),
                                )
                              : null,
                        ),
                        if (!_isOtpSent) ...[
                          const SizedBox(height: 24),
                          GradientButton(
                            text: 'SEND VERIFICATION CODE',
                            onPressed: _isSendingOtp ? null : _sendOtp,
                            isLoading: _isSendingOtp,
                            icon: Icons.send_rounded,
                          ),
                        ],
                        if (_isOtpSent && !_isOtpVerified) ...[
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _otpCtrl,
                            label: 'Verification Code',
                            hint: '123456',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.verified_user_outlined,
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            text: 'VERIFY CODE',
                            onPressed: _isVerifyingOtp ? null : _verifyOtp,
                            isLoading: _isVerifyingOtp,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (_isOtpVerified) ...[
                    const SizedBox(height: 32),
                    _sectionLabel('Biometric Data'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _firstNameCtrl,
                            label: 'First Name',
                            hint: 'Jane',
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _lastNameCtrl,
                            label: 'Last Name',
                            hint: 'Smith',
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _phoneCtrl,
                      label: 'Emergency Mobile',
                      hint: '+1 234 567 890',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_android_rounded,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _passwordCtrl,
                      label: 'Security Key',
                      hint: 'Min. 8 characters',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_open_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF94A3B8), size: 18),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Too short' : null,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _confirmPasswordCtrl,
                      label: 'Confirm Key',
                      hint: '••••••••',
                      obscureText: true,
                      prefixIcon: Icons.verified_user_outlined,
                      validator: (v) => (v != _passwordCtrl.text) ? 'Mismatch' : null,
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      text: 'COMPLETE ENROLLMENT',
                      onPressed: _isLoading ? null : _register,
                      isLoading: _isLoading,
                      icon: Icons.assignment_turned_in_rounded,
                    ),
                  ],

                  const SizedBox(height: 32),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/auth/login'),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          children: [
                            const TextSpan(text: 'ALREADY ENROLLED? '),
                            TextSpan(
                              text: 'SIGN IN',
                              style: TextStyle(color: const Color(0xFF0284C7), fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!.toUpperCase(),
              style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF0284C7), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0284C7),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

