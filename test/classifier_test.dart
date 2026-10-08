import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:agri_ai/features/camera_scan/data/crop_disease_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Classifier diagnoses healthy leaf accurately', () async {
    final testImage = img.Image(width: 100, height: 100);
    for (int y = 0; y < 100; y++) {
      for (int x = 0; x < 100; x++) {
        testImage.setPixelRgb(x, y, 40, 180, 50); // Healthy green
      }
    }
    final tempFile = File('test_healthy_leaf.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(testImage));

    try {
      final classifier = HybridCropDiseaseClassifier();
      final results = await classifier.classifyImage(tempFile.path, language: 'si');

      expect(results.isNotEmpty, true);
      final first = results.first;
      expect(first.isHealthy, true);
      expect(first.confidence > 0.9, true);
    } finally {
      if (await tempFile.exists()) await tempFile.delete();
    }
  });

  test('Classifier diagnoses diseased leaf with lesions & necrosis', () async {
    final testImage = img.Image(width: 100, height: 100);
    for (int y = 0; y < 100; y++) {
      for (int x = 0; x < 100; x++) {
        // 70% green, 30% necrotic brown spots
        if ((x > 30 && x < 65) && (y > 30 && y < 65)) {
          testImage.setPixelRgb(x, y, 140, 60, 20); // Necrotic lesion
        } else {
          testImage.setPixelRgb(x, y, 40, 180, 50); // Leaf green
        }
      }
    }
    final tempFile = File('test_diseased_leaf.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(testImage));

    try {
      final classifier = HybridCropDiseaseClassifier();
      final results = await classifier.classifyImage(tempFile.path, language: 'si');

      expect(results.isNotEmpty, true);
      final first = results.first;
      print('Diseased label: ${first.label}');
      print('Disease name: ${first.diseaseName}');
      print('Severity: ${first.severity}');
      print('Treatment plan:\n${first.treatmentPlan}');
      expect(first.isHealthy, false);
      expect(first.diseaseName.isNotEmpty, true);
      expect(first.treatmentPlan.isNotEmpty, true);
    } finally {
      if (await tempFile.exists()) await tempFile.delete();
    }
  });
}
