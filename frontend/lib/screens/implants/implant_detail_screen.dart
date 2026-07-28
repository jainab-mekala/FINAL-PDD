import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/implant_model.dart';
import '../../models/assessment_model.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class ImplantDetailScreen extends ConsumerWidget {
  final String implantId;
  const ImplantDetailScreen({super.key, required this.implantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final implantAsync = ref.watch(implantProvider(implantId));
    final assessmentsAsync = ref.watch(assessmentsForImplantProvider(implantId));

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
          child: implantAsync.when(
            data: (implant) {
              if (implant == null) return const Center(child: Text('Implant not found'));
              return Column(
                children: [
                  _buildHeader(context, implant),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusCard(implant),
                          const SizedBox(height: 24),
                          _buildSectionHeader('HARDWARE PARAMETERS'),
                          const SizedBox(height: 16),
                          _buildImplantSpecs(implant),
                          const SizedBox(height: 32),
                          GradientButton(
                            text: 'INITIATE NEURAL ANALYSIS',
                            onPressed: () => context.go('/ai-prediction/$implantId'),
                            icon: Icons.psychology_rounded,
                          ),
                          const SizedBox(height: 32),
                          assessmentsAsync.when(
                            data: (assessments) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (assessments.length >= 2) ...[
                                  _buildSectionHeader('PROBING DEPTH TREND'),
                                  const SizedBox(height: 16),
                                  _buildTrendChart(assessments),
                                  const SizedBox(height: 32),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSectionHeader('SURVEILLANCE LOG'),
                                    TextButton(
                                      onPressed: () => context.go('/monitoring/add/$implantId'),
                                      child: Text(
                                        'ADD ENTRY',
                                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF00F0FF), letterSpacing: 1),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildAssessmentHistory(context, assessments, implantId),
                              ],
                            ),
                            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00F0FF))),
                            error: (e, _) => Text('Error: $e'),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00F0FF))),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Implant implant) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'IMPLANT TERMINAL',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_chart_rounded, color: Color(0xFF00F0FF), size: 22),
            onPressed: () => context.go('/monitoring/add/$implantId'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF00F0FF), letterSpacing: 2),
        ),
        const SizedBox(width: 16),
        Expanded(child: Divider(color: const Color(0xFF00F0FF).withOpacity(0.1))),
      ],
    );
  }

  Widget _buildStatusCard(Implant implant) {
    final statusColor = _getStatusColor(implant.currentStatus);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      opacity: 0.05,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
              ],
            ),
            child: Center(
              child: Text(
                '#${implant.position.toothNumber}',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0D0720)),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  implant.brand.toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                Text(
                  implant.model,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white38),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    implant.statusLabel.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(implant.riskScore * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: statusColor),
              ),
              Text(
                'RISK LEVEL',
                style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImplantSpecs(Implant implant) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      opacity: 0.03,
      child: Column(
        children: [
          _SpecRow(label: 'ARCH / SIDE', value: '${implant.position.arch.toUpperCase()} · ${implant.position.side.toUpperCase()}'),
          const Divider(height: 24, color: Colors.white10),
          _SpecRow(label: 'DIMENSIONS', value: '${implant.diameter} × ${implant.length} MM'),
          const Divider(height: 24, color: Colors.white10),
          _SpecRow(label: 'PLACEMENT', value: DateFormat('MMM d, yyyy').format(implant.placementDate).toUpperCase()),
          const Divider(height: 24, color: Colors.white10),
          _SpecRow(label: 'SERVICE PERIOD', value: '${implant.monthsSincePlacement} MONTHS'),
          if (implant.boneGraftType != null) ...[
            const Divider(height: 24, color: Colors.white10),
            _SpecRow(label: 'BONE GRAFT', value: implant.boneGraftType!.toUpperCase()),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<Assessment> assessments) {
    final sorted = assessments.reversed.toList();
    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.probingDepths.max);
    }).toList();

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      opacity: 0.05,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (v, m) => Text('${v.toStringAsFixed(0)}mm', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white24)),
                      reservedSize: 32,
                    ),
                  ),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 12,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF00F0FF),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(radius: 4, color: const Color(0xFF00F0FF), strokeWidth: 2, strokeColor: const Color(0xFF0D0720)),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF00F0FF).withOpacity(0.2), const Color(0xFF00F0FF).withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: List.generate(spots.length, (i) => FlSpot(i.toDouble(), 6.0)),
                    isCurved: false,
                    color: const Color(0xFFFF4444).withOpacity(0.3),
                    barWidth: 1,
                    dashArray: [4, 4],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(const Color(0xFF00F0FF), 'MAX DEPTH'),
              const SizedBox(width: 24),
              _buildChartLegend(const Color(0xFFFF4444).withOpacity(0.5), 'CRITICAL LIMIT (6MM)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 2, color: color),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildAssessmentHistory(BuildContext context, List<Assessment> assessments, String implantId) {
    if (assessments.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(40),
        opacity: 0.03,
        child: Center(
          child: Text('NO CLINICAL RECORDS FOUND', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white10, letterSpacing: 2)),
        ),
      );
    }

    return Column(
      children: assessments.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _AssessmentTile(assessment: a),
      )).toList(),
    );
  }

  Color _getStatusColor(ImplantStatus status) {
    switch (status) {
      case ImplantStatus.healthy: return const Color(0xFF00FF9F);
      case ImplantStatus.watchlist: return const Color(0xFFFFD700);
      case ImplantStatus.atRisk: return const Color(0xFFFF6B35);
      case ImplantStatus.critical: return const Color(0xFFFF4444);
      case ImplantStatus.failed: return const Color(0xFF888888);
    }
  }
}

class _AssessmentTile extends StatelessWidget {
  final Assessment assessment;
  const _AssessmentTile({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final statusColor = assessment.isCritical ? const Color(0xFFFF4444) : const Color(0xFF00FF9F);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      opacity: 0.05,
      border: Border.all(color: statusColor.withOpacity(0.1)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(assessment.assessmentDate).toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
              ),
              const Spacer(),
              if (assessment.predictedRiskScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF00F0FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'AI SCORE: ${(assessment.predictedRiskScore! * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF00F0FF)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('PROBING DEPTH', '${assessment.probingDepths.max.toStringAsFixed(1)}mm', assessment.probingDepths.max >= 6),
              _buildMiniStat('BONE CHANGE', '${assessment.boneLevelChange.toStringAsFixed(1)}mm', assessment.boneLevelChange >= 2),
              _buildMiniStat('BLEEDING', assessment.bleedingOnProbing == BleedingOnProbing.present ? 'YES' : 'NO', assessment.bleedingOnProbing == BleedingOnProbing.present),
              _buildMiniStat('SUPPURATION', assessment.suppuration == Suppuration.present ? 'YES' : 'NO', assessment.suppuration == Suppuration.present),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, bool alert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: alert ? const Color(0xFFFF6B35) : Colors.white70),
        ),
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 1)),
        Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }
}

