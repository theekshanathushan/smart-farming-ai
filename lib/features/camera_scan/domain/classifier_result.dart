class ClassifierResult {
  final String label;
  final double confidence;

  ClassifierResult({
    required this.label,
    required this.confidence,
  });

  @override
  String toString() {
    return 'ClassifierResult(label: $label, confidence: ${(confidence * 100).toStringAsFixed(2)}%)';
  }
}
