/// Cyber risk output model.
library;

class CyberRiskOutput {
  final double riskScore;
  final String threatCategory;
  final String confidence;
  final List<String> reasons;
  final List<String> recommendedActions;

  const CyberRiskOutput({
    required this.riskScore,
    required this.threatCategory,
    required this.confidence,
    required this.reasons,
    required this.recommendedActions,
  });

  factory CyberRiskOutput.safe() {
    return const CyberRiskOutput(
      riskScore: 0,
      threatCategory: 'Safe',
      confidence: 'High',
      reasons: ['No threats detected'],
      recommendedActions: ['Continue with normal usage'],
    );
  }

  Map<String, dynamic> toMap() => {
    'riskScore': riskScore,
    'threatCategory': threatCategory,
    'confidence': confidence,
    'reasons': reasons,
    'recommendedActions': recommendedActions,
  };
}
