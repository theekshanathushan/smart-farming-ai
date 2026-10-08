class ClassifierResult {
  final String label;
  final double confidence;
  final bool isHealthy;
  final String diseaseName;
  final String treatmentPlan;
  final String severity;

  // Comprehensive plant & agronomic fields
  final String plantName;
  final String cropType;
  final String botanicalName;
  final String symptoms;
  final String immediateActions;
  final String organicRemedies;
  final String chemicalRemedies;
  final String preventiveTips;
  final bool isPlant;

  ClassifierResult({
    required this.label,
    required this.confidence,
    this.isHealthy = false,
    this.diseaseName = '',
    this.treatmentPlan = '',
    this.severity = 'Unknown',
    this.plantName = '',
    this.cropType = '',
    this.botanicalName = '',
    this.symptoms = '',
    this.immediateActions = '',
    this.organicRemedies = '',
    this.chemicalRemedies = '',
    this.preventiveTips = '',
    this.isPlant = true,
  });

  @override
  String toString() {
    return 'ClassifierResult(label: $label, plant: $plantName, cropType: $cropType, confidence: ${(confidence * 100).toStringAsFixed(2)}%, healthy: $isHealthy, disease: $diseaseName)';
  }
}
