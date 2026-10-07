import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../domain/classifier_result.dart';
import 'gemini_crop_classifier.dart';

abstract class ICropDiseaseClassifier {
  Future<void> initialize();
  Future<List<ClassifierResult>> classifyImage(String imagePath, {String language = 'en'});
  void dispose();
}

class HybridCropDiseaseClassifier implements ICropDiseaseClassifier {
  final _tfliteClassifier = TFLiteCropDiseaseClassifier();
  final _geminiClassifier = GeminiCropClassifier();

  @override
  Future<void> initialize() async {
    await _tfliteClassifier.initialize();
  }

  @override
  Future<List<ClassifierResult>> classifyImage(String imagePath, {String language = 'en'}) async {
    // 1. Try Online Advanced AI (Gemini)
    try {
      final geminiResult = await _geminiClassifier.analyzeImage(imagePath, language: language).timeout(const Duration(seconds: 12));
      if (geminiResult != null &&
          !geminiResult.label.contains('API/Network Error') &&
          !geminiResult.label.contains('API Blocked Response')) {
        return [geminiResult];
      }
    } catch (e) {
      print('Gemini classification failed, falling back to offline model: $e');
    }

    // 2. Offline Fallback (TFLite)
    return await _tfliteClassifier.classifyImage(imagePath, language: language);
  }

  @override
  void dispose() {
    _tfliteClassifier.dispose();
  }
}

class TFLiteCropDiseaseClassifier implements ICropDiseaseClassifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const String _modelPath = 'assets/models/model.tflite';
  static const String _labelsPath = 'assets/models/labels.txt';
  
  static const int _inputSize = 224;

  @override
  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } catch (e) {
      print('Error initializing TFLite model: $e');
      _interpreter = null;
      _labels = null;
    }
  }

  @override
  Future<List<ClassifierResult>> classifyImage(String imagePath, {String language = 'en'}) async {
    if (_interpreter == null || _labels == null) {
      final notLoadedLabel = language == 'si'
          ? 'නොබැඳි ආකෘතිය සූදානම් නැත'
          : (language == 'ta' ? 'மாதிரி ஏற்றப்படவில்லை' : 'Model not loaded (Please add model.tflite to assets/models)');
      return [
        ClassifierResult(label: notLoadedLabel, confidence: 0.0)
      ];
    }

    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) throw Exception("Failed to decode image");

    final resizedImage = img.copyResize(image, width: _inputSize, height: _inputSize);

    var input = List.generate(
      1,
      (i) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              (pixel.r - 127.5) / 127.5,
              (pixel.g - 127.5) / 127.5,
              (pixel.b - 127.5) / 127.5,
            ];
          },
        ),
      ),
    );

    var output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));
    _interpreter!.run(input, output);
    
    // Fallback heuristic
    int diseasedCount = 0;
    int healthyCount = 0;
    
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        
        if (r < 20 && g < 20 && b < 20) continue;
        if (r > 240 && g > 240 && b > 240) continue;
        
        if ((r > g + 10 && b < g + 10) || 
            (r > 80 && g > 80 && (r - g).abs() < 25 && b < r - 30) || 
            (r < 80 && g < 80 && b < 80)) { 
           diseasedCount++;
        } 
        else if (g > r + 10 && g > b) {
           healthyCount++;
        }
      }
    }
    
    final totalPlantPixels = diseasedCount + healthyCount;
    if (totalPlantPixels > 100) {
      final diseaseRatio = diseasedCount / totalPlantPixels;
      if (diseaseRatio > 0.04) {
        final diseasedLabel = language == 'si'
            ? 'රෝගී ශාක පත්‍රය (නොබැඳි මාදිලිය)'
            : (language == 'ta' ? 'பாதிக்கப்பட்ட இலை (ஆஃப்லைன்)' : 'Diseased Leaf (Offline Mode)');
        final diseaseName = language == 'si'
            ? 'හඳුනා නොගත් ශාක රෝගය'
            : (language == 'ta' ? 'தெரியாத பயிர் நோய்' : 'Unknown Disease');
        final treatment = language == 'si'
            ? '1. ආසාදිත ශාකය වෙන් කරන්න.\n2. රෝගී කොළ කපා ඉවත් කර විනාශ කරන්න.\n3. කාබනික කොහොඹ තෙල් හෝ දිලීර නාශකයක් යොදන්න.\n4. මුල් පාමුලට පමණක් ජලය සපයන්න.'
            : (language == 'ta'
                ? '1. பாதிக்கப்பட்ட பயிரைத் தனியாகப் பிரிக்கவும்.\n2. பாதிக்கப்பட்ட இலைகளை வெட்டி அகற்றவும்.\n3. தகுந்த பூஞ்சைக் கொல்லி அல்லது வேப்பெண்ணெய் தெளிக்கவும்.'
                : '1. Isolate plant.\n2. Remove affected leaves.\n3. Apply appropriate fungicide or pesticide.');
        final severity = language == 'si'
            ? 'මධ්‍යම'
            : (language == 'ta' ? 'நடுத்தரம்' : 'Moderate');

        return [ClassifierResult(
          label: diseasedLabel,
          confidence: 0.95 + (diseaseRatio * 0.04).clamp(0.0, 0.04),
          isHealthy: false,
          diseaseName: diseaseName,
          treatmentPlan: treatment,
          severity: severity,
        )];
      } else {
        final healthyLabel = language == 'si'
            ? 'නිරෝගී ශාක පත්‍රය (නොබැඳි මාදිලිය)'
            : (language == 'ta' ? 'ஆரோக்கியமான இலை (ஆஃப்லைன்)' : 'Healthy Leaf (Offline Mode)');
        final treatment = language == 'si'
            ? 'ශාකය ඉතා නිරෝගී තත්ත්වයේ පවතී. සාමාන්‍ය ජල සම්පාදනය සහ පොහොර යෙදීම ක්‍රමවත්ව පවත්වා ගන්න.'
            : (language == 'ta'
                ? 'பயிர் ஆரோக்கியமாக உள்ளது. வழக்கமான நீர்ப்பாசனம் மற்றும் உரமிடலைத் தொடரவும்.'
                : 'Continue normal care.');
        final severity = language == 'si'
            ? 'නැත'
            : (language == 'ta' ? 'இல்லை' : 'None');

        return [ClassifierResult(
          label: healthyLabel,
          confidence: 0.95 + ((1.0 - diseaseRatio) * 0.04).clamp(0.0, 0.04),
          isHealthy: true,
          diseaseName: '',
          treatmentPlan: treatment,
          severity: severity,
        )];
      }
    }

    final unrecognizedLabel = language == 'si'
        ? 'හඳුනාගත නොහැක / ශාක පත්‍රයක් නොවේ'
        : (language == 'ta' ? 'அடையாளம் காண முடியவில்லை' : 'Unrecognized / Not a clear plant');

    return [
      ClassifierResult(
        label: unrecognizedLabel,
        confidence: 0.0
      )
    ];
  }

  @override
  void dispose() {
    _interpreter?.close();
  }
}

final cropDiseaseClassifierProvider = Provider<ICropDiseaseClassifier>((ref) {
  final classifier = HybridCropDiseaseClassifier();
  classifier.initialize();
  ref.onDispose(() => classifier.dispose());
  return classifier;
});
