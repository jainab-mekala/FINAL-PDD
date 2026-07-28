import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background Bar with frosted glass effect
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFE8E2D9),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26231F).withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => context.go('/dashboard'),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  isSelected: currentIndex == 1,
                  onTap: () => context.go('/reports'),
                ),
                const SizedBox(width: 64), // Spacer for floating center button
                _NavItem(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Suggestions',
                  isSelected: currentIndex == 3,
                  onTap: () => context.go('/suggestions'),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),

          // ── Floating Center Button ──
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => context.go('/public-analyzer'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD97757),
                          Color(0xFFC15C3D),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97757).withOpacity(0.35),
                          blurRadius: 16,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: currentIndex == 2 ? 32 : 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI Analyzer',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: currentIndex == 2
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: currentIndex == 2
                          ? const Color(0xFFD97757)
                          : const Color(0xFF6E6860),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFD97757);
    final inactiveColor = const Color(0xFFA39C93);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF5ECE5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
