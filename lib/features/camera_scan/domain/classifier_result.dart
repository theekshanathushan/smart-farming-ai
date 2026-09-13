class ClassifierResult {
  final String label;
  final double confidence;
  final bool isHealthy;
  final String diseaseName;
  final String treatmentPlan;
  final String severity;

  ClassifierResult({
    required this.label,
    required this.confidence,
    this.isHealthy = false,
    this.diseaseName = '',
    this.treatmentPlan = '',
    this.severity = 'Unknown',
  });

  @override
  String toString() {
    return 'ClassifierResult(label: $label, confidence: ${(confidence * 100).toStringAsFixed(2)}%, healthy: $isHealthy, disease: $diseaseName)';
  }
}
