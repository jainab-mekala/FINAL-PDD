import 'dart:math';
import '../models/prediction_model.dart';
import '../models/assessment_model.dart';
import '../models/patient_model.dart';
import '../models/implant_model.dart';

/// ImplantGuard AI™ Core Prediction Engine
/// 
/// Uses a multi-factor weighted scoring model combining:
/// - Clinical parameters (probing depth, bone level, BOP, suppuration)
/// - Patient risk factors (systemic disease, smoking, etc.)
/// - Longitudinal trend analysis
/// - Evidence-based clinical thresholds from:
///   * Berglundh et al. (2018) classification
///   * Renvert et al. peri-implantitis staging
///   * EFP/AAP guidelines 2019
class AIPredictionService {
  static const Map<String, double> _featureWeights = {
    'maxProbingDepth': 0.20,
    'boneLevelChange': 0.22,
    'bleedingOnProbing': 0.12,
    'suppuration': 0.14,
    'mobility': 0.10,
    'mucositis': 0.05,
    'smoking': 0.04,
    'diabetes': 0.04,
    'plaqueScore': 0.03,
    'probingTrend': 0.06,
  };

  /// Main prediction function
  /// Returns [PredictionResult] with risk score, level, and recommendations
  Future<PredictionResult> predict({
    required Patient patient,
    required Implant implant,
    required List<Assessment> assessmentHistory,
  }) async {
    // Simulate async operation for future TFLite integration
    await Future.delayed(const Duration(milliseconds: 800));

    if (assessmentHistory.isEmpty) {
      return _buildBaselineResult(patient, implant);
    }

    final sortedAssessments = List<Assessment>.from(assessmentHistory)
      ..sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));

    final latest = sortedAssessments.first;
    final input = _buildPredictionInput(patient, implant, sortedAssessments);
    
    // Compute weighted risk score
    double rawScore = _computeRiskScore(input, latest);
    
    // Apply trend multiplier
    rawScore = _applyTrendMultiplier(rawScore, sortedAssessments);
    
    // Clamp to [0,1]
    final finalScore = rawScore.clamp(0.0, 1.0);
    
    // Determine risk level
    final riskLevel = _classifyRiskLevel(finalScore, latest);
    
    // Build recommendations
    final recommendations = _generateRecommendations(input, latest, riskLevel);
    
    // Feature contributions
    final contributions = _computeFeatureContributions(input, latest);
    
    // Primary risk factors (top 3)
    final primaryFactors = _identifyPrimaryFactors(input, latest, contributions);
    
    // Explanation
    final explanation = _buildExplanation(riskLevel, primaryFactors, finalScore);
    
    // Time to intervention estimate
    final monthsToIntervention = _estimateTimeToIntervention(finalScore, sortedAssessments);
    
    // Confidence based on data quality
    final confidence = _computeConfidence(assessmentHistory.length, latest);

    return PredictionResult(
      riskScore: finalScore,
      riskLevel: riskLevel,
      confidence: confidence,
      primaryRiskFactors: primaryFactors,
      recommendations: recommendations,
      explanation: explanation,
      featureContributions: contributions,
      predictedAt: DateTime.now(),
      monthsToIntervention: monthsToIntervention,
    );
  }

  PredictionInput _buildPredictionInput(
    Patient patient,
    Implant implant,
    List<Assessment> sorted,
  ) {
    final latest = sorted.first;
    
    // Compute trends from last 3-5 assessments
    double probingTrend = 0.0;
    double boneLossTrend = 0.0;
    
    if (sorted.length >= 2) {
      final depths = sorted.take(5).map((a) => a.probingDepths.max).toList();
      final boneLoss = sorted.take(5).map((a) => a.boneLevelChange).toList();
      probingTrend = _computeSlope(depths);
      boneLossTrend = _computeSlope(boneLoss);
    }

    return PredictionInput(
      patientAge: patient.age,
      isDiabetic: patient.medicalConditions
          .any((c) => c.toLowerCase().contains('diabet')),
      isSmoker: patient.smokingStatus == SmokingStatus.currentSmoker,
      hasOsteoporosis: patient.medicalConditions
          .any((c) => c.toLowerCase().contains('osteoporosis')),
      hasPeriodontalHistory: patient.hasPeriodontalHistory,
      bmi: patient.bmi,
      monthsSincePlacement: implant.monthsSincePlacement,
      hadComplicationsAtPlacement: implant.hadComplicationsAtPlacement,
      maxProbingDepth: latest.probingDepths.max,
      avgProbingDepth: latest.probingDepths.average,
      boneLevelChange: latest.boneLevelChange,
      bleedingOnProbing: latest.bleedingOnProbing == BleedingOnProbing.present,
      suppuration: latest.suppuration == Suppuration.present,
      mobilityGrade: latest.mobility.index,
      plaqueScore: latest.plaqueScore ?? 0.0,
      mucositisPresent: latest.mucositisPresent,
      probingDepthTrend: probingTrend,
      boneLossTrend: boneLossTrend,
      assessmentCount: sorted.length,
    );
  }

  double _computeRiskScore(PredictionInput input, Assessment latest) {
    double score = 0.0;

    // === CLINICAL PARAMETERS (highest weight) ===
    
    // Probing depth contribution (Berglundh threshold: 6mm+)
    final pd = input.maxProbingDepth;
    if (pd < 4.0) score += _featureWeights['maxProbingDepth']! * 0.1;
    else if (pd < 5.0) score += _featureWeights['maxProbingDepth']! * 0.3;
    else if (pd < 6.0) score += _featureWeights['maxProbingDepth']! * 0.6;
    else if (pd < 7.0) score += _featureWeights['maxProbingDepth']! * 0.8;
    else score += _featureWeights['maxProbingDepth']! * 1.0;

    // Bone level change (>2mm = peri-implantitis per 2018 classification)
    final blc = input.boneLevelChange;
    if (blc < 0.5) score += _featureWeights['boneLevelChange']! * 0.0;
    else if (blc < 1.0) score += _featureWeights['boneLevelChange']! * 0.3;
    else if (blc < 2.0) score += _featureWeights['boneLevelChange']! * 0.7;
    else if (blc < 3.0) score += _featureWeights['boneLevelChange']! * 0.9;
    else score += _featureWeights['boneLevelChange']! * 1.0;

    // Bleeding on probing
    if (input.bleedingOnProbing) {
      score += _featureWeights['bleedingOnProbing']! * 0.8;
    }

    // Suppuration (strong indicator)
    if (input.suppuration) {
      score += _featureWeights['suppuration']! * 1.0;
    }

    // Mobility
    if (input.mobilityGrade > 0) {
      score += _featureWeights['mobility']! * (input.mobilityGrade / 3.0);
    }

    // Mucositis (precursor to peri-implantitis)
    if (input.mucositisPresent) {
      score += _featureWeights['mucositis']! * 0.6;
    }

    // === PATIENT RISK FACTORS ===
    if (input.isSmoker) {
      score += _featureWeights['smoking']! * 1.0;
    }
    if (input.isDiabetic) {
      score += _featureWeights['diabetes']! * 1.0;
    }
    if (input.hasPeriodontalHistory) {
      score += 0.03;
    }
    if (input.hasOsteoporosis) {
      score += 0.02;
    }

    // Plaque score
    final plaqueContrib = (input.plaqueScore / 100.0) * _featureWeights['plaqueScore']!;
    score += plaqueContrib;

    // Trend components
    if (input.probingDepthTrend > 0) {
      score += _featureWeights['probingTrend']! * min(1.0, input.probingDepthTrend);
    }

    return score;
  }

  double _applyTrendMultiplier(double score, List<Assessment> sorted) {
    if (sorted.length < 3) return score;

    // Check if last 3 assessments show worsening
    final last3 = sorted.take(3).toList();
    bool worseningTrend = last3[0].probingDepths.max > last3[1].probingDepths.max &&
        last3[1].probingDepths.max > last3[2].probingDepths.max;

    if (worseningTrend) {
      return score * 1.25; // 25% amplifier for consistent worsening
    }

    // Improving trend - slight reduction
    bool improvingTrend = last3[0].probingDepths.max < last3[1].probingDepths.max &&
        last3[1].probingDepths.max < last3[2].probingDepths.max;

    if (improvingTrend) {
      return score * 0.85;
    }

    return score;
  }

  RiskLevel _classifyRiskLevel(double score, Assessment latest) {
    // Override to critical if hard clinical criteria met
    if (latest.periImplantitisDetected ||
        latest.suppuration == Suppuration.present && latest.boneLevelChange >= 2.0) {
      return RiskLevel.critical;
    }

    if (score < 0.25) return RiskLevel.low;
    if (score < 0.50) return RiskLevel.moderate;
    if (score < 0.75) return RiskLevel.high;
    return RiskLevel.critical;
  }

  List<ClinicalRecommendation> _generateRecommendations(
    PredictionInput input,
    Assessment latest,
    RiskLevel level,
  ) {
    final List<ClinicalRecommendation> recs = [];

    switch (level) {
      case RiskLevel.low:
        recs.add(ClinicalRecommendation(
          title: 'Routine Maintenance',
          description: 'Schedule standard 6-month recall visit with professional decontamination.',
          priority: RecommendationPriority.routine,
          timeframe: '6 months',
          evidenceLevel: 'A',
        ));
        recs.add(ClinicalRecommendation(
          title: 'Patient Education',
          description: 'Reinforce optimal oral hygiene protocol including interdental cleaning.',
          priority: RecommendationPriority.preventive,
          timeframe: 'Next visit',
          evidenceLevel: 'A',
        ));
        break;

      case RiskLevel.moderate:
        recs.add(ClinicalRecommendation(
          title: 'Enhanced Recall Protocol',
          description: 'Reduce recall interval to 3-4 months. Perform detailed probing charting.',
          priority: RecommendationPriority.routine,
          timeframe: '3-4 months',
          evidenceLevel: 'A',
        ));
        recs.add(ClinicalRecommendation(
          title: 'Professional Decontamination',
          description: 'Mechanical debridement with titanium scalers + chlorhexidine irrigation.',
          priority: RecommendationPriority.urgent,
          timeframe: '4-6 weeks',
          evidenceLevel: 'B',
        ));
        if (input.plaqueScore > 30) {
          recs.add(ClinicalRecommendation(
            title: 'Plaque Control Intervention',
            description: 'Oral hygiene instruction with demonstrated technique for implant sites.',
            priority: RecommendationPriority.routine,
            timeframe: 'Immediate',
            evidenceLevel: 'A',
          ));
        }
        break;

      case RiskLevel.high:
        recs.add(ClinicalRecommendation(
          title: 'Immediate Clinical Intervention',
          description: 'Non-surgical peri-implant therapy required: subgingival debridement + local antimicrobials.',
          priority: RecommendationPriority.urgent,
          timeframe: '2-4 weeks',
          evidenceLevel: 'A',
        ));
        recs.add(ClinicalRecommendation(
          title: 'Radiographic Assessment',
          description: 'Periapical radiograph to quantify bone loss. Compare with baseline.',
          priority: RecommendationPriority.urgent,
          timeframe: '1-2 weeks',
          evidenceLevel: 'A',
        ));
        if (input.isSmoker) {
          recs.add(ClinicalRecommendation(
            title: 'Smoking Cessation Referral',
            description: 'Strongly advise smoking cessation. Refer to cessation program. Smoking increases peri-implantitis risk by 3.6×.',
            priority: RecommendationPriority.urgent,
            timeframe: 'Immediate',
            evidenceLevel: 'A',
          ));
        }
        if (input.isDiabetic) {
          recs.add(ClinicalRecommendation(
            title: 'Glycemic Control Review',
            description: 'Coordinate with patient physician. HbA1c >7% significantly worsens implant prognosis.',
            priority: RecommendationPriority.urgent,
            timeframe: 'This visit',
            evidenceLevel: 'B',
          ));
        }
        break;

      case RiskLevel.critical:
        recs.add(ClinicalRecommendation(
          title: '⚠️ URGENT: Surgical Consultation',
          description: 'Refer for surgical peri-implantitis therapy. Resective or regenerative approach based on defect morphology.',
          priority: RecommendationPriority.immediate,
          timeframe: 'Within 1-2 weeks',
          evidenceLevel: 'A',
        ));
        recs.add(ClinicalRecommendation(
          title: 'Systemic Antibiotics',
          description: 'Consider adjunct systemic antibiotics (Azithromycin 500mg or Metronidazole + Amoxicillin) after specialist evaluation.',
          priority: RecommendationPriority.immediate,
          timeframe: 'Immediate',
          evidenceLevel: 'B',
        ));
        recs.add(ClinicalRecommendation(
          title: 'Implant Removal Assessment',
          description: 'Evaluate implant salvageability. Document advanced bone loss for treatment planning.',
          priority: RecommendationPriority.immediate,
          timeframe: 'At surgical consultation',
          evidenceLevel: 'A',
        ));
        break;
    }

    return recs;
  }

  Map<String, double> _computeFeatureContributions(
    PredictionInput input,
    Assessment latest,
  ) {
    return {
      'Probing Depth': _normalizeProbingContrib(input.maxProbingDepth),
      'Bone Level Change': _normalizeBoneContrib(input.boneLevelChange),
      'Bleeding on Probing': input.bleedingOnProbing ? 0.85 : 0.1,
      'Suppuration': input.suppuration ? 1.0 : 0.0,
      'Mobility': input.mobilityGrade / 3.0,
      'Plaque Score': input.plaqueScore / 100.0,
      'Smoking': input.isSmoker ? 1.0 : 0.0,
      'Diabetes': input.isDiabetic ? 1.0 : 0.0,
      'Worsening Trend': input.probingDepthTrend > 0 ? min(1.0, input.probingDepthTrend) : 0.0,
    };
  }

  List<String> _identifyPrimaryFactors(
    PredictionInput input,
    Assessment latest,
    Map<String, double> contributions,
  ) {
    final sorted = contributions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(3)
        .where((e) => e.value > 0.2)
        .map((e) => e.key)
        .toList();
  }

  String _buildExplanation(
    RiskLevel level,
    List<String> factors,
    double score,
  ) {
    final factorStr = factors.isEmpty
        ? 'no dominant risk factors'
        : factors.join(', ');

    switch (level) {
      case RiskLevel.low:
        return 'This implant shows low risk of peri-implantitis (${(score * 100).toStringAsFixed(0)}%). '
            'Clinical parameters are within acceptable limits. Continue routine maintenance protocol.';
      case RiskLevel.moderate:
        return 'Moderate risk detected (${(score * 100).toStringAsFixed(0)}%). '
            'Key contributing factors: $factorStr. '
            'Enhanced monitoring and professional decontamination recommended.';
      case RiskLevel.high:
        return 'High risk of peri-implantitis progression (${(score * 100).toStringAsFixed(0)}%). '
            'Primary factors: $factorStr. '
            'Immediate clinical intervention required to prevent irreversible bone loss.';
      case RiskLevel.critical:
        return 'CRITICAL: Active peri-implantitis likely (${(score * 100).toStringAsFixed(0)}%). '
            'Factors driving risk: $factorStr. '
            'Urgent surgical consultation required. Implant survival at risk.';
    }
  }

  int _estimateTimeToIntervention(double score, List<Assessment> sorted) {
    if (score >= 0.75) return 0; // Immediate
    if (score >= 0.5) return 4;  // 4 weeks
    if (score >= 0.35) return 12; // 3 months
    return 26; // 6 months routine
  }

  double _computeConfidence(int assessmentCount, Assessment latest) {
    double conf = 0.5; // Base confidence

    // More data = higher confidence
    conf += min(0.3, assessmentCount * 0.05);

    // Recent assessment = higher confidence
    final daysSince = DateTime.now().difference(latest.assessmentDate).inDays;
    if (daysSince < 30) conf += 0.15;
    else if (daysSince < 90) conf += 0.1;
    else if (daysSince < 180) conf += 0.05;

    // Has radiograph = higher confidence
    if (latest.xrayImageUrl != null) conf += 0.05;

    return conf.clamp(0.5, 0.97);
  }

  double _computeSlope(List<double> values) {
    if (values.length < 2) return 0.0;
    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i.toDouble();
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i.toDouble() * i.toDouble();
    }

    final denom = n * sumX2 - sumX * sumX;
    if (denom == 0) return 0.0;

    return (n * sumXY - sumX * sumY) / denom;
  }

  double _normalizeProbingContrib(double pd) {
    if (pd < 4.0) return 0.05;
    if (pd < 5.0) return 0.3;
    if (pd < 6.0) return 0.6;
    if (pd < 7.0) return 0.8;
    return 1.0;
  }

  double _normalizeBoneContrib(double blc) {
    if (blc < 0.5) return 0.0;
    if (blc < 1.0) return 0.3;
    if (blc < 2.0) return 0.65;
    if (blc < 3.0) return 0.9;
    return 1.0;
  }

  PredictionResult _buildBaselineResult(Patient patient, Implant implant) {
    // Risk score for new implant with no assessments
    double score = 0.1;
    if (patient.smokingStatus == SmokingStatus.currentSmoker) score += 0.1;
    if (patient.medicalConditions.any((c) => c.toLowerCase().contains('diabet'))) score += 0.08;
    if (patient.hasPeriodontalHistory) score += 0.06;
    if (implant.hadComplicationsAtPlacement) score += 0.1;

    return PredictionResult(
      riskScore: score.clamp(0.0, 1.0),
      riskLevel: score < 0.2 ? RiskLevel.low : RiskLevel.moderate,
      confidence: 0.5,
      primaryRiskFactors: ['Insufficient data — baseline assessment needed'],
      recommendations: [
        ClinicalRecommendation(
          title: 'Baseline Assessment Required',
          description: 'Perform initial probing depth charting and periapical radiograph to establish baseline measurements.',
          priority: RecommendationPriority.routine,
          timeframe: 'Within 1 month',
          evidenceLevel: 'A',
        ),
      ],
      explanation: 'Risk assessment is based on patient profile only. Clinical assessment data is needed for accurate prediction.',
      featureContributions: {
        'Patient Risk Factors': score,
        'Clinical Data': 0.0,
      },
      predictedAt: DateTime.now(),
      monthsToIntervention: 26,
    );
  }
}
