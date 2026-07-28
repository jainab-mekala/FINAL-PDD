import 'package:flutter/material.dart';
import '../models/prediction_model.dart';

class RecommendationCard extends StatelessWidget {
  final ClinicalRecommendation recommendation;
  const RecommendationCard({super.key, required this.recommendation});

  Color get _priorityColor {
    switch (recommendation.priority) {
      case RecommendationPriority.immediate: return const Color(0xFFDC2626);
      case RecommendationPriority.urgent: return const Color(0xFFE65100);
      case RecommendationPriority.routine: return const Color(0xFFD97757);
      case RecommendationPriority.preventive: return const Color(0xFF388E3C);
    }
  }

  String get _priorityLabel {
    switch (recommendation.priority) {
      case RecommendationPriority.immediate: return 'IMMEDIATE';
      case RecommendationPriority.urgent: return 'URGENT';
      case RecommendationPriority.routine: return 'ROUTINE';
      case RecommendationPriority.preventive: return 'PREVENTIVE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26231F).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  _priorityLabel,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Level ${recommendation.evidenceLevel}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6E6860)),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Color(0xFF6E6860)),
                  const SizedBox(width: 4),
                  Text(
                    recommendation.timeframe,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6E6860)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.title,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF26231F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6E6860),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

