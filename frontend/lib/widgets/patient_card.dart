import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({super.key, required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E2D9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26231F).withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5ECE5),
                border: Border.all(color: const Color(0xFFD97757).withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  patient.firstName.isNotEmpty
                      ? patient.firstName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97757),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF26231F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${patient.age} yrs · ${patient.implantIds.length} implant(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6E6860),
                    ),
                  ),
                ],
              ),
            ),
            // Risk indicators
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (patient.smokingStatus == SmokingStatus.currentSmoker)
                  _RiskBadge(label: 'Smoker', color: const Color(0xFFD97757)),
                if (patient.medicalConditions
                    .any((c) => c.toLowerCase().contains('diabet')))
                  _RiskBadge(label: 'DM', color: const Color(0xFFD97706)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFA39C93), size: 20),
          ],
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _RiskBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

