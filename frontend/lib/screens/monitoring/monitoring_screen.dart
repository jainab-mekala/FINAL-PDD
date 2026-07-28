import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/implant_model.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_bottom_nav.dart';

class MonitoringScreen extends ConsumerWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final implantsAsync = ref.watch(allImplantsProvider);

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
              Expanded(
                child: implantsAsync.when(
                  data: (implants) {
                    if (implants.isEmpty) {
                      return _buildEmptyState();
                    }

                    final sorted = List<Implant>.from(implants)
                      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: sorted.length,
                      itemBuilder: (context, i) {
                        final implant = sorted[i];
                        return _MonitoringCard(
                          implant: implant,
                          onTap: () => context.go('/implants/${implant.id}'),
                          onAI: () => context.go('/ai-prediction/${implant.id}'),
                          onAssess: () => context.go('/monitoring/add/${implant.id}'),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00F0FF))),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE SURVEILLANCE',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00F0FF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Active Monitoring',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          GlassContainer(
            width: 44,
            height: 44,
            borderRadius: 12,
            opacity: 0.1,
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            width: 100,
            height: 100,
            borderRadius: 50,
            opacity: 0.05,
            child: Icon(Icons.monitor_heart_outlined, size: 40, color: Colors.white.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'NO ACTIVE SIGNALS',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Initialize patients to begin surveillance',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.2),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringCard extends StatelessWidget {
  final Implant implant;
  final VoidCallback onTap;
  final VoidCallback onAI;
  final VoidCallback onAssess;

  const _MonitoringCard({
    required this.implant,
    required this.onTap,
    required this.onAI,
    required this.onAssess,
  });

  Color get _statusColor {
    switch (implant.currentStatus) {
      case ImplantStatus.healthy: return const Color(0xFF00FF9F);
      case ImplantStatus.watchlist: return const Color(0xFFFFD700);
      case ImplantStatus.atRisk: return const Color(0xFFFF6B35);
      case ImplantStatus.critical: return const Color(0xFFFF4444);
      case ImplantStatus.failed: return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        opacity: 0.05,
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: implant.riskScore,
                        strokeWidth: 3,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Text(
                      '${(implant.riskScore * 100).toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOOTH #${implant.position.toothNumber}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        implant.brand,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Text(
                    implant.statusLabel.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'ASSESS',
                    icon: Icons.add_chart_rounded,
                    onTap: onAssess,
                    color: const Color(0xFF00F0FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'AI ANALYZE',
                    icon: Icons.psychology_rounded,
                    onTap: onAI,
                    color: const Color(0xFFB388FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


