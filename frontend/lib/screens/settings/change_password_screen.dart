import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_container.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).changePassword(
        currentPassword: _currentPasswordCtrl.text,
        newPassword: _newPasswordCtrl.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Security Key updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String error = 'Update failure';
        if (e.toString().contains('wrong-password')) error = 'Current key incorrect';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0720),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Security Protocol', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0720), Color(0xFF1A0D3A)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_currentPasswordCtrl, 'Current Security Key', Icons.lock_outline, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent)),
                const SizedBox(height: 20),
                _buildTextField(_newPasswordCtrl, 'New Security Key', Icons.lock_reset_rounded, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
                const SizedBox(height: 16),
                _buildTextField(_confirmPasswordCtrl, 'Confirm New Key', Icons.verified_user_outlined, true, null),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _update,
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('UPDATE SECURITY KEY'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, bool obscure, VoidCallback? toggleObscure) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF00F0FF)),
          suffixIcon: toggleObscure != null 
            ? IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white24, size: 18), onPressed: toggleObscure)
            : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required';
          if (ctrl == _confirmPasswordCtrl && v != _newPasswordCtrl.text) return 'Mismatch';
          if (ctrl == _newPasswordCtrl && v.length < 6) return 'Min 6 chars';
          return null;
        },
      ),
    );
  }
}
