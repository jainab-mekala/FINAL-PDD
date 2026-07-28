enum RiskLevel { low, moderate, high, critical }

class PredictionInput {
  // Patient risk factors
  final int patientAge;
  final bool isDiabetic;
  final bool isSmoker;
  final bool hasOsteoporosis;
  final bool hasPeriodontalHistory;
  final double? bmi;

  // Implant factors
  final int monthsSincePlacement;
  final bool hadComplicationsAtPlacement;

  // Clinical parameters (most recent assessment)
  final double maxProbingDepth;
  final double avgProbingDepth;
  final double boneLevelChange;
  final bool bleedingOnProbing;
  final bool suppuration;
  final int mobilityGrade; // 0-3
  final double plaqueScore;
  final bool mucositisPresent;

  // Trend data (last 3 assessments)
  final double probingDepthTrend; // slope
  final double boneLossTrend; // slope
  final int assessmentCount;

  PredictionInput({
    required this.patientAge,
    required this.isDiabetic,
    required this.isSmoker,
    required this.hasOsteoporosis,
    required this.hasPeriodontalHistory,
    this.bmi,
    required this.monthsSincePlacement,
    required this.hadComplicationsAtPlacement,
    required this.maxProbingDepth,
    required this.avgProbingDepth,
    required this.boneLevelChange,
    required this.bleedingOnProbing,
    required this.suppuration,
    required this.mobilityGrade,
    required this.plaqueScore,
    required this.mucositisPresent,
    required this.probingDepthTrend,
    required this.boneLossTrend,
    required this.assessmentCount,
  });

  List<double> toFeatureVector() {
    return [
      patientAge / 100.0,
      isDiabetic ? 1.0 : 0.0,
      isSmoker ? 1.0 : 0.0,
      hasOsteoporosis ? 1.0 : 0.0,
      hasPeriodontalHistory ? 1.0 : 0.0,
      (bmi ?? 25.0) / 50.0,
      monthsSincePlacement / 120.0,
      hadComplicationsAtPlacement ? 1.0 : 0.0,
      maxProbingDepth / 12.0,
      avgProbingDepth / 12.0,
      boneLevelChange / 5.0,
      bleedingOnProbing ? 1.0 : 0.0,
      suppuration ? 1.0 : 0.0,
      mobilityGrade / 3.0,
      plaqueScore / 100.0,
      mucositisPresent ? 1.0 : 0.0,
      probingDepthTrend.clamp(-1.0, 1.0),
      boneLossTrend.clamp(-1.0, 1.0),
      assessmentCount / 20.0,
    ];
  }
}

class PredictionResult {
  final double riskScore; // 0.0 - 1.0
  final RiskLevel riskLevel;
  final double confidence; // 0.0 - 1.0
  final List<String> primaryRiskFactors;
  final List<ClinicalRecommendation> recommendations;
  final String explanation;
  final Map<String, double> featureContributions;
  final DateTime predictedAt;
  final int monthsToIntervention; // estimated months before clinical intervention needed

  PredictionResult({
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
    required this.primaryRiskFactors,
    required this.recommendations,
    required this.explanation,
    required this.featureContributions,
    required this.predictedAt,
    required this.monthsToIntervention,
  });

  String get riskPercentage => '${(riskScore * 100).toStringAsFixed(1)}%';

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical Risk';
    }
  }
}

class ClinicalRecommendation {
  final String title;
  final String description;
  final RecommendationPriority priority;
  final String timeframe;
  final String evidenceLevel; // "A", "B", "C" - evidence levels

  ClinicalRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.timeframe,
    required this.evidenceLevel,
  });
}

enum RecommendationPriority { immediate, urgent, routine, preventive }
