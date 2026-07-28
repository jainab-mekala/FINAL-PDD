import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_bottom_nav.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final criticalAsync = ref.watch(criticalImplantsProvider);

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
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
                background: Stack(
                  children: [
                    // Decorative light glow
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD97757).withOpacity(0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: profileAsync.when(
                        data: (profile) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF5ECE5),
                                    border: Border.all(color: const Color(0xFFD97757).withOpacity(0.3)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      profile?.firstName.isNotEmpty == true
                                          ? profile!.firstName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Color(0xFFD97757),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                        fontFamily: 'Outfit',
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
                                        profile?.firstName.isNotEmpty == true
                                            ? 'Hello, ${profile!.firstName}'
                                            : 'Clinical Dashboard',
                                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF26231F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF388E3C),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'SYSTEMS ACTIVE · LIVE',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF388E3C),
                                              letterSpacing: 0.8,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Notification button
                                _NotificationButton(criticalAsync: criticalAsync),
                              ],
                            ),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    statsAsync.when(
                      data: (stats) => Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Total Analyses',
                              value: '${stats['implants'] ?? 0}',
                              icon: Icons.analytics_outlined,
                              color: const Color(0xFFD97757),
                              onTap: () => context.go('/reports'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              label: 'High Risk cases',
                              value: '${stats['critical'] ?? 0}',
                              icon: Icons.warning_amber_outlined,
                              color: const Color(0xFFE65100),
                              isAlert: (stats['critical'] ?? 0) > 0,
                              onTap: () => context.go('/monitoring'),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFD97757)),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 32),

                    // Quick actions section
                    const _SectionHeader(title: 'Clinical Intelligence'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _QuickAction(
                          icon: Icons.biotech_outlined,
                          label: 'AI RISK\nANALYZER',
                          color: const Color(0xFF388E3C),
                          onTap: () => context.go('/public-analyzer'),
                        ),
                        const SizedBox(width: 16),
                        _QuickAction(
                          icon: Icons.lightbulb_outline_rounded,
                          label: 'CLINICAL\nSUGGESTIONS',
                          color: const Color(0xFFD97757),
                          onTap: () => context.go('/suggestions'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _QuickAction(
                          icon: Icons.person_outline_rounded,
                          label: 'USER\nPROFILE',
                          color: const Color(0xFFC15C3D),
                          onTap: () => context.go('/settings'),
                        ),
                        const SizedBox(width: 16),
                        _QuickAction(
                          icon: Icons.assessment_outlined,
                          label: 'SYSTEM\nREPORTS',
                          color: const Color(0xFFD97706),
                          onTap: () => context.go('/reports'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // System Info Card
                    GestureDetector(
                      onTap: () => context.push('/settings/about'),
                      child: Container(
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5ECE5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.info_outline, color: Color(0xFFD97757)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AI Model v2.4.0 Active',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF26231F),
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Last encrypted sync: 2 minutes ago',
                                    style: TextStyle(
                                      color: const Color(0xFF6E6860),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFFA39C93)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final AsyncValue<dynamic> criticalAsync;
  const _NotificationButton({required this.criticalAsync});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF26231F)),
          onPressed: () {},
        ),
        criticalAsync.when(
          data: (critical) => (critical as List).isNotEmpty
              ? Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFDC2626).withOpacity(0.5), blurRadius: 4),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFFD97757),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E2D9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF26231F).withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF26231F),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

