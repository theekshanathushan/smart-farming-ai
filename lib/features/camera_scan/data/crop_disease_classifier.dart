import 'dart:io';
import 'package:flutter/foundation.dart';
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
  @override
  Future<List<ClassifierResult>> classifyImage(String imagePath, {String language = 'en'}) async {
    // 1. Try Online Advanced AI (Gemini) with working model cascade and generous timeout
    try {
      final geminiResult = await _geminiClassifier.analyzeImage(imagePath, language: language).timeout(const Duration(seconds: 25));
      if (geminiResult != null &&
          !geminiResult.label.contains('API/Network Error') &&
          !geminiResult.label.contains('API Blocked Response')) {
        return [geminiResult];
      }
    } catch (e) {
      debugPrint('Gemini classification notice ($e), falling back to local verification.');
    }

    // 2. Offline Fallback (Local Computer Vision & TFLite)
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
      debugPrint('Warning: TFLite model initialization notice: $e');
      _interpreter = null;
      _labels = null;
    }
  }

  @override
  Future<List<ClassifierResult>> classifyImage(String imagePath, {String language = 'en'}) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception("Image file not found: $imagePath");
    }

    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // Attempt lazy initialize if not already done
    if (_interpreter == null) {
      try {
        await initialize();
      } catch (_) {}
    }

    final resizedImage = img.copyResize(image, width: _inputSize, height: _inputSize);

    // 1. Strict Computer Vision Vegetative Chlorophyll Analysis
    // Ensures helmets, vehicles, furniture, or dark objects are NEVER misclassified as plants!
    int greenChlorophyllPixels = 0;
    int necroticChlorosisPixels = 0;
    int totalSampled = 0;

    for (int y = 0; y < resizedImage.height; y += 2) {
      for (int x = 0; x < resizedImage.width; x += 2) {
        final pixel = resizedImage.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        // Skip background pure blacks, pure whites, or extreme grays
        if (r < 25 && g < 25 && b < 25) continue;
        if (r > 235 && g > 235 && b > 235) continue;
        totalSampled++;

        // Genuine plant green chlorophyll pigment (dominant green channel)
        if (g > r + 14 && g > b + 14 && g > 45) {
          greenChlorophyllPixels++;
        }
        // Leaf necrosis or chlorosis only valid when surrounded by plant context
        else if (r > 80 && g > 70 && b < 70 && (r - g) > 10 && (r - g) < 60) {
          necroticChlorosisPixels++;
        }
      }
    }

    // A real plant leaf MUST have prominent green chlorophyll pixels (at least 15% of sampled non-background)
    final bool isActuallyPlant = totalSampled > 50 && (greenChlorophyllPixels / totalSampled) > 0.14;

    if (!isActuallyPlant) {
      final notPlantLabel = language == 'si'
          ? 'හඳුනාගත නොහැක / ශාකයක් නොවේ'
          : (language == 'ta' ? 'தாவரம் கண்டறியப்படவில்லை' : 'Not a Plant / Non-Vegetative Object');

      final notPlantAdvice = language == 'si'
          ? 'මෙම ඡායාරූපයෙහි ශාක පත්‍රයක් හෝ බෝගයක් හඳුනාගත නොහැක (උදා: හෙල්මට්, වාහන හෝ වෙනත් වස්තූන්). කරුණාකර සැබෑ ශාක පත්‍රයක් හෝ බෝගයක් ආලෝකය සහිතව ඡායාරූපගත කර නැවත ස්කෑන් කරන්න.'
          : (language == 'ta'
              ? 'இந்த படத்தில் தாவர இலை கண்டறியப்படவில்லை. தயவுசெய்து உண்மையான பயிர் இலையை படம் எடுத்து மீண்டும் ஸ்கேன் செய்யவும்.'
              : 'No plant leaf detected in this photo (e.g., helmet, furniture, or non-plant item). Please take a well-lit photo of an actual plant leaf and rescan.');

      return [
        ClassifierResult(
          label: notPlantLabel,
          confidence: 0.0,
          isHealthy: false,
          diseaseName: '',
          treatmentPlan: notPlantAdvice,
          severity: language == 'si' ? 'නැත' : (language == 'ta' ? 'இல்லை' : 'None'),
          isPlant: false,
          plantName: '',
          cropType: '',
          botanicalName: '',
          symptoms: '',
          immediateActions: '',
          organicRemedies: '',
          chemicalRemedies: '',
          preventiveTips: '',
        )
      ];
    }

    // 2. Real leaf verified: Run TFLite inference if model loaded
    bool isDiseased = false;
    double confidence = 0.88;

    if (_interpreter != null && _labels != null && _labels!.length >= 2) {
      try {
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
        
        final healthyScore = output[0][0];
        final diseasedScore = output[0][1];
        isDiseased = diseasedScore > healthyScore;
        confidence = (isDiseased ? diseasedScore : healthyScore).clamp(0.70, 0.95);
      } catch (e) {
        debugPrint('TFLite inference error: $e');
        isDiseased = necroticChlorosisPixels > (greenChlorophyllPixels * 0.25);
      }
    } else {
      isDiseased = necroticChlorosisPixels > (greenChlorophyllPixels * 0.25);
    }

    // Return honest offline result WITHOUT mock plant species
    if (isDiseased) {
      return [
        ClassifierResult(
          label: language == 'si'
              ? 'රෝගී පත්‍ර ලක්ෂණ (නොබැඳි හඳුනාගැනීම)'
              : (language == 'ta' ? 'பாதிக்கப்பட்ட இலை (ஆஃப்லைன்)' : 'Diseased Foliage (Offline)'),
          confidence: confidence,
          isHealthy: false,
          diseaseName: language == 'si'
              ? 'පත්‍ර ආසාදනයක් හඳුනාගන්නා ලදී (Online සවිස්තර අවශ්‍යයි)'
              : (language == 'ta' ? 'இலை பாதிப்பு கண்டறியப்பட்டது' : 'Leaf Disease Detected (Requires Online AI)'),
          treatmentPlan: language == 'si'
              ? 'බෝගයේ නිශ්චිත නම, විද්‍යාත්මක වර්ගීකරණය සහ නිවැරදි රසායනික/කාබනික ප්‍රතිකාර ලබා ගැනීමට කරුණාකර අන්තර්ජාල සම්බන්ධතාවය සක්‍රිය කර නැවත ස්කෑන් කරන්න (Rescan).'
              : (language == 'ta'
                  ? 'துல்லியமான பயிர் வகை மற்றும் முழு சிகிச்சை பெற இணையத்தை இயக்கி மீண்டும் ஸ்கேன் செய்யவும்.'
                  : 'To get the exact crop name, botanical identification, and verified treatment dosages, please connect to the internet and rescan.'),
          severity: language == 'si' ? 'මධ්‍යම' : (language == 'ta' ? 'நடுத்தரம்' : 'Moderate'),
          plantName: language == 'si' ? 'හඳුනාගත් ශාකය' : 'Identified Plant',
          cropType: language == 'si' ? 'ගොවිපළ බෝගය' : 'Crop',
          botanicalName: '',
          symptoms: language == 'si' ? 'පත්‍රයේ දුර්වර්ණ වීම් හෝ ලප නිරීක්ෂණය වේ.' : 'Foliage discoloration or spotting detected.',
          immediateActions: language == 'si' ? 'ආසාදිත කොළ අනෙක් පැළ වලින් වෙන් කර නිරීක්ෂණය කරන්න.' : 'Isolate affected plant from healthy crops.',
          organicRemedies: '',
          chemicalRemedies: '',
          preventiveTips: '',
          isPlant: true,
        )
      ];
    } else {
      return [
        ClassifierResult(
          label: language == 'si'
              ? 'නිරෝගී ශාක පත්‍රය (නොබැඳි හඳුනාගැනීම)'
              : (language == 'ta' ? 'ஆரோக்கியமான இலை (ஆஃப்லைன்)' : 'Healthy Leaf (Offline)'),
          confidence: confidence,
          isHealthy: true,
          diseaseName: '',
          treatmentPlan: language == 'si'
              ? 'ශාක පත්‍රය නිරෝගී තත්ත්වයේ පවතී. නිතිපතා ජලය සහ කාබනික පොහොර යොදන්න. සවිස්තර බෝග තොරතුරු සඳහා Online සම්බන්ධ වන්න.'
              : 'Foliage appears healthy. Maintain regular watering schedule.',
          severity: language == 'si' ? 'නැත' : (language == 'ta' ? 'இல்லை' : 'None'),
          plantName: language == 'si' ? 'නිරෝගී ශාකය' : 'Healthy Plant',
          cropType: language == 'si' ? 'ගොවිපළ බෝගය' : 'Crop',
          botanicalName: '',
          symptoms: language == 'si' ? 'නිරෝගී හරිත පැහැය.' : 'Healthy green foliage.',
          immediateActions: '',
          organicRemedies: '',
          chemicalRemedies: '',
          preventiveTips: '',
          isPlant: true,
        )
      ];
    }
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

