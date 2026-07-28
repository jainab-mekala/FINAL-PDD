import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:implantguard_ai/providers/auth_provider.dart';
import 'package:implantguard_ai/widgets/custom_bottom_nav.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      userAsync.when(
                        data: (user) => _buildProfileCard(context, user),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 28),
                      _SettingsSection(
                        title: 'ACCESS CONTROL',
                        items: [
                          _SettingItem(
                            icon: Icons.badge_outlined,
                            label: 'Profile Management',
                            onTap: () => context.push('/settings/profile'),
                          ),
                          _SettingItem(
                            icon: Icons.lock_reset_rounded,
                            label: 'Change Password',
                            onTap: () => context.push('/settings/change-password'),
                          ),
                          _SettingItem(
                            icon: Icons.notifications_active_outlined,
                            label: 'Surveillance Alerts',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Real-time surveillance alerts are ACTIVE',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: const Color(0xFF388E3C),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SettingsSection(
                        title: 'DOCUMENTATION',
                        items: [
                          _SettingItem(
                            icon: Icons.article_outlined,
                            label: 'Terms of Access',
                            onTap: () => context.push('/settings/terms'),
                          ),
                          _SettingItem(
                            icon: Icons.verified_user_outlined,
                            label: 'Privacy Protocol',
                            onTap: () => context.push('/settings/privacy'),
                          ),
                          _SettingItem(
                            icon: Icons.info_outline_rounded,
                            label: 'System Version',
                            trailing: 'v2.4.0',
                            onTap: () => context.push('/settings/about'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSignOutButton(context, ref),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97757),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'SYSTEM PREFERENCES',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97757),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Settings',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF26231F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E2D9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26231F).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5ECE5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD97757).withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                user?.firstName.isNotEmpty == true
                    ? user!.firstName[0].toUpperCase()
                    : 'U',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFD97757),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'User',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF26231F),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF6E6860),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (user?.phone?.isNotEmpty == true) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.phone_android_rounded, size: 12, color: Color(0xFFD97757)),
                      const SizedBox(width: 5),
                      Text(
                        user!.phone,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF6E6860),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/settings/profile'),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF5ECE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded, color: Color(0xFFD97757), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Sign Out',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: const Color(0xFF26231F)),
            ),
            content: Text(
              'Are you sure you want to sign out of your account?',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6E6860), height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(color: const Color(0xFF6E6860), fontWeight: FontWeight.w700),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Sign Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(authServiceProvider).signOut();
          if (context.mounted) context.go('/auth/login');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC2626).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
            const SizedBox(width: 10),
            Text(
              'SIGN OUT',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFDC2626),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingItem> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97757),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97757),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E2D9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF26231F).withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                      color: const Color(0xFFE8E2D9),
                      height: 1,
                      indent: 56,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5ECE5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFD97757), size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          color: const Color(0xFF26231F),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing!,
              style: GoogleFonts.outfit(
                color: const Color(0xFF6E6860),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFFA39C93), size: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
