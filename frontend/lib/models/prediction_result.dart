class PredictionResult {
  final double score;
  final String riskLevel;
  final String message;

  PredictionResult({
    required this.score,
    required this.riskLevel,
    required this.message,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      score: (json["implantguard_risk_score"] as num).toDouble(),
      riskLevel: json["risk_level"],
      message: json["message"],
    );
  }
}
