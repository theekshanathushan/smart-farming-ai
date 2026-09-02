import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart';
import '../data/crop_disease_classifier.dart';
import '../domain/classifier_result.dart';
import '../../../core/local_db/app_database.dart';
import '../../../main.dart'; 

class ScanState {
  final bool isLoading;
  final String? imagePath;
  final ClassifierResult? result;
  final String? error;
  final bool isSaved;

  ScanState({
    this.isLoading = false,
    this.imagePath,
    this.result,
    this.error,
    this.isSaved = false,
  });

  ScanState copyWith({
    bool? isLoading,
    String? imagePath,
    ClassifierResult? result,
    String? error,
    bool? isSaved,
  }) {
    return ScanState(
      isLoading: isLoading ?? this.isLoading,
      imagePath: imagePath ?? this.imagePath,
      result: result ?? this.result,
      error: error ?? this.error,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class ScanController extends StateNotifier<ScanState> {
  final ICropDiseaseClassifier _classifier;
  final AppDatabase _db;
  final ImagePicker _picker = ImagePicker();

  ScanController(this._classifier, this._db) : super(ScanState());

  Future<void> captureAndClassify(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      state = state.copyWith(isLoading: true, imagePath: image.path, error: null, isSaved: false);

      final results = await _classifier.classifyImage(image.path);
      
      state = state.copyWith(
        isLoading: false,
        result: results.isNotEmpty ? results.first : null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveResult(String? notes) async {
    if (state.imagePath == null || state.result == null) return;

    try {
      await _db.insertScanResult(ScanResultsCompanion(
        imagePath: Value(state.imagePath!),
        predictedLabel: Value(state.result!.label),
        confidence: Value(state.result!.confidence),
        timestamp: Value(DateTime.now()),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ));
      state = state.copyWith(isSaved: true);
    } catch (e) {
      state = state.copyWith(error: "Failed to save: $e");
    }
  }

  void reset() {
    state = ScanState();
  }
}

final scanControllerProvider = StateNotifierProvider<ScanController, ScanState>((ref) {
  final classifier = ref.watch(cropDiseaseClassifierProvider);
  final db = ref.watch(databaseProvider);
  return ScanController(classifier, db);
});
