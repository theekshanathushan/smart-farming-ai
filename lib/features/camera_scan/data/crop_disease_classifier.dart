import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../domain/classifier_result.dart';

abstract class ICropDiseaseClassifier {
  Future<void> initialize();
  Future<List<ClassifierResult>> classifyImage(String imagePath);
  void dispose();
}

class TFLiteCropDiseaseClassifier implements ICropDiseaseClassifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const String _modelPath = 'assets/models/model.tflite';
  static const String _labelsPath = 'assets/models/labels.txt';
  
  // Default to MobileNetV2 standards if not overridden
  static const int _inputSize = 224;

  @override
  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } catch (e) {
      // Print error but don't crash entirely; allows UI to show placeholder or error
      print('Error initializing TFLite model: $e');
      _interpreter = null;
      _labels = null;
    }
  }

  @override
  Future<List<ClassifierResult>> classifyImage(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      return [
        ClassifierResult(label: 'Model not loaded (Please add model.tflite to assets/models)', confidence: 0.0)
      ];
    }

    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) throw Exception("Failed to decode image");

    // Resize
    final resizedImage = img.copyResize(image, width: _inputSize, height: _inputSize);

    // Normalize to float32 [1, 224, 224, 3]
    var input = List.generate(
      1,
      (i) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    // Prepare output array (Assuming output shape is [1, num_classes])
    var output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));

    // Run inference
    _interpreter!.run(input, output);

    // Map output to labels
    final resultScores = output[0];
    final results = <ClassifierResult>[];
    for (int i = 0; i < resultScores.length; i++) {
      results.add(ClassifierResult(label: _labels![i], confidence: resultScores[i]));
    }

    // Sort by confidence (descending)
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return results;
  }

  @override
  void dispose() {
    _interpreter?.close();
  }
}

final cropDiseaseClassifierProvider = Provider<ICropDiseaseClassifier>((ref) {
  final classifier = TFLiteCropDiseaseClassifier();
  // Initialize asynchronously.
  classifier.initialize();
  ref.onDispose(() => classifier.dispose());
  return classifier;
});
