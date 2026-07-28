import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/patient_model.dart';
import '../../models/implant_model.dart';
import '../../widgets/risk_chip.dart';

class PatientDetailScreen extends ConsumerWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientProvider(patientId));
    final implantsAsync = ref.watch(implantsByPatientProvider(patientId));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: patientAsync.when(
          data: (patient) {
            if (patient == null) {
              return const Center(
                  child: Text('Patient not found',
                      style: TextStyle(color: Color(0xFF0F172A))));
            }
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, ref, patient),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatientInfo(patient),
                        const SizedBox(height: 32),
                        _buildRiskFactors(patient),
                        const SizedBox(height: 32),
                        _buildImplantsSection(context, ref, implantsAsync),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF0284C7))),
          error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: Color(0xFFEF4444)))),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, WidgetRef ref, Patient patient) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFFF8FAFC),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Color(0xFF0F172A)),
        onPressed: () => context.go('/patients'),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded,
              color: Color(0xFF0284C7)),
          onPressed: () => context.go('/implants/add?patientId=$patientId'),
          tooltip: 'Add Implant',
        ),
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF64748B)),
          onPressed: () {},
          tooltip: 'Edit Patient',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.blurBackground],
        background: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF0284C7).withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            patient.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0284C7),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.fullName,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${patient.age} yrs · ${patient.gender.name.toUpperCase()} · ID: ${patientId.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
              label: 'Date of Birth',
              value: DateFormat('MMM d, yyyy').format(patient.dateOfBirth)),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _InfoRow(label: 'Email', value: patient.email ?? 'Not provided'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _InfoRow(label: 'Phone', value: patient.phone ?? 'Not provided'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _InfoRow(
              label: 'Smoking Status',
              value: _smokingLabel(patient.smokingStatus),
              valueColor: patient.smokingStatus == SmokingStatus.currentSmoker
                  ? const Color(0xFFD97706)
                  : const Color(0xFF059669)),
          if (patient.bmi != null) ...[
            const Divider(height: 32, color: Color(0xFFF1F5F9)),
            _InfoRow(label: 'BMI', value: patient.bmi!.toStringAsFixed(1)),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskFactors(Patient patient) {
    final factors = <String>[];
    if (patient.medicalConditions.isNotEmpty)
      factors.addAll(patient.medicalConditions);
    if (patient.hasPeriodontalHistory) factors.add('Periodontal History');
    if (patient.smokingStatus == SmokingStatus.currentSmoker)
      factors.add('Active Smoker');

    if (factors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Clinical Risk Factors'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: factors.map((f) => RiskChip(label: f)).toList(),
        ),
      ],
    );
  }

  Widget _buildImplantsSection(BuildContext context, WidgetRef ref,
      AsyncValue<List<Implant>> implantsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel(text: 'Implant Surveillance'),
            TextButton.icon(
              onPressed: () => context.go('/implants/add?patientId=$patientId'),
              icon: const Icon(Icons.add_rounded,
                  size: 18, color: Color(0xFF0284C7)),
              label: const Text('NEW IMPLANT',
                  style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        implantsAsync.when(
          data: (implants) {
            if (implants.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.hardware_rounded,
                          size: 48, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 16),
                      const Text('No active implant surveillance',
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: implants
                  .map((imp) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ImplantListTile(
                          implant: imp,
                          onTap: () => context.go('/implants/${imp.id}'),
                          onAI: () => context.go('/ai-prediction/${imp.id}'),
                        ),
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF0284C7))),
          error: (e, _) => Text('Error: $e',
              style: const TextStyle(color: Color(0xFFEF4444))),
        ),
      ],
    );
  }

  String _smokingLabel(SmokingStatus status) {
    switch (status) {
      case SmokingStatus.nonSmoker:
        return 'Non-Smoker';
      case SmokingStatus.formerSmoker:
        return 'Former Smoker';
      case SmokingStatus.currentSmoker:
        return 'Current Smoker';
    }
  }
}

class _ImplantListTile extends StatelessWidget {
  final Implant implant;
  final VoidCallback onTap;
  final VoidCallback onAI;

  const _ImplantListTile({
    required this.implant,
    required this.onTap,
    required this.onAI,
  });

  Color get _statusColor {
    switch (implant.currentStatus) {
      case ImplantStatus.healthy:
        return const Color(0xFF059669);
      case ImplantStatus.watchlist:
        return const Color(0xFFD97706);
      case ImplantStatus.atRisk:
        return const Color(0xFFEA580C);
      case ImplantStatus.critical:
        return const Color(0xFFDC2626);
      case ImplantStatus.failed:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tooth #${implant.position.toothNumber} · ${implant.brand}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${implant.diameter}×${implant.length}mm · ${implant.monthsSincePlacement}mo post-op',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(implant.riskScore * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _statusColor,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  implant.statusLabel.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      color: _statusColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Text('🧠', style: TextStyle(fontSize: 16)),
                onPressed: onAI,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600)),
        Text(value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
                color: const Color(0xFF0284C7),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0284C7),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
