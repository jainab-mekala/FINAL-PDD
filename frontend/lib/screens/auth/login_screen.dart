import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() {
        _errorMessage = _parseFirebaseError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseFirebaseError(String error) {
    if (error.contains('user-not-found') || error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Invalid clinical credentials';
    }
    if (error.contains('user-disabled')) return 'Terminal access suspended';
    if (error.contains('network')) return 'Encrypted link failure';
    return 'Authentication protocol error';
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.biotech_rounded, size: 42, color: Color(0xFF0284C7)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'AUTHORIZATION',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0284C7),
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'CLINICAL PORTAL',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(),
                      const SizedBox(height: 24),
                    ],
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
                            controller: _emailController,
                            label: 'Clinical Identifier (Email)',
                            hint: 'doctor@implantguard.ai',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.badge_outlined,
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Access Key',
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.vpn_key_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF94A3B8), size: 18),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                            onSubmitted: (_) => _login(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'RESET KEY',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      text: 'INITIALIZE ACCESS',
                      onPressed: _isLoading ? null : _login,
                      isLoading: _isLoading,
                      icon: Icons.lock_open_rounded,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NEW CLINICAL USER? ',
                          style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/auth/register'),
                          child: Text(
                            'REGISTER TERMINAL',
                            style: GoogleFonts.outfit(color: const Color(0xFF0284C7), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
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
}

