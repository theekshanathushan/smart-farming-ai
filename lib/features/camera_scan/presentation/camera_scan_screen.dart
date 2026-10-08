import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'scan_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_ai/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../domain/classifier_result.dart';

class CameraScanScreen extends ConsumerWidget {
  const CameraScanScreen({super.key});

  void _askAiAboutScan(BuildContext context, WidgetRef ref, ClassifierResult result, [String? imagePath]) {
    final currentLang = ref.read(localeProvider).languageCode;
    final isUnrecognized = result.confidence == 0 ||
        result.label.contains('Unrecognized') ||
        result.label.contains('හඳුනාගත නොහැක') ||
        result.label.contains('அடையாளம்');
    final isDiseased = !result.isHealthy && !isUnrecognized;
    final isHealthy = result.isHealthy && !isUnrecognized;
    
    final condition = result.diseaseName.isNotEmpty ? result.diseaseName : result.label;
    final plant = result.plantName.isNotEmpty ? result.plantName : (isDiseased ? condition : 'Plant');

    String prompt;
    if (isDiseased) {
      if (currentLang == 'si') {
        prompt = 'මගේ බෝගයේ කොළ ස්කෑන් කළ විට හඳුනාගත් විස්තර පහත දැක්වේ:\n\n'
            '• ශාකයේ නම: $plant\n'
            '${result.cropType.isNotEmpty ? '• බෝග වර්ගය: ${result.cropType}\n' : ''}'
            '${result.botanicalName.isNotEmpty ? '• උද්භිද විද්‍යාත්මක නම: ${result.botanicalName}\n' : ''}'
            '• හඳුනාගත් රෝගය: $condition\n'
            '• බරපතලකම (Severity): ${result.severity}\n'
            '${result.symptoms.isNotEmpty ? '• ප්‍රධාන රෝග ලක්ෂණ: ${result.symptoms}\n' : ''}'
            '• ආකෘති විශ්වාසනීයත්වය: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
            '${result.treatmentPlan.isNotEmpty ? '• මූලික සැලැස්ම: ${result.treatmentPlan}\n' : ''}\n'
            'කරුණාකර මෙම රෝගය සුව කිරීමට අවශ්‍ය සවිස්තරාත්මක ප්‍රතිකාර, ස්වාභාවික හා කාබනික ක්‍රම, රසායනික මාත්‍රා, සහ නැවත බෝවීම වැළැක්වීමේ පියවර කරුණු වශයෙන් (Point by point) පැහැදිලිව ලබා දෙන්න.';
      } else if (currentLang == 'ta') {
        prompt = 'எனது பயிரின் இலை ஸ்கேன் செய்யப்பட்டதன் முடிவுகள்:\n\n'
            '• பயிர் பெயர்: $plant\n'
            '${result.cropType.isNotEmpty ? '• பயிர் வகை: ${result.cropType}\n' : ''}'
            '• கண்டறியப்பட்ட நோய்: $condition\n'
            '• தீவிரம்: ${result.severity}\n'
            '• மாதிரி துல்லியம்: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
            'தயவுசெய்து இந்த நோயைக் கட்டுப்படுத்த இயற்கை முறைகள், மருந்து பரிந்துரைகள் மற்றும் தடுப்பு வழிகளை குறிப்புகளாக (Point by point) தெளிவாக விளக்குங்கள்.';
      } else {
        prompt = 'I scanned a crop leaf and the diagnosis returned the following details:\n\n'
            '• Plant Name: $plant\n'
            '${result.cropType.isNotEmpty ? '• Crop Category: ${result.cropType}\n' : ''}'
            '${result.botanicalName.isNotEmpty ? '• Botanical Name: ${result.botanicalName}\n' : ''}'
            '• Condition / Disease: $condition\n'
            '• Severity: ${result.severity}\n'
            '${result.symptoms.isNotEmpty ? '• Visible Symptoms: ${result.symptoms}\n' : ''}'
            '• Model Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%\n\n'
            'Please provide comprehensive, point-by-point advice covering:\n'
            '1. Diagnosis & Pathology\n'
            '2. Immediate Field Actions (Pruning & Isolation)\n'
            '3. Organic & Natural Treatments with exact preparation\n'
            '4. Chemical Controls with recommended dosages\n'
            '5. Irrigation & Long-term Prevention';
      }
    } else if (isHealthy) {
      if (currentLang == 'si') {
        prompt = 'මගේ බෝගය ($plant) නිරෝගී ලෙස ස්කෑන් කර ඇත. ${result.botanicalName.isNotEmpty ? "(${result.botanicalName}) " : ""}මෙම බෝගයේ නිරෝගීභාවය රැකගෙන උපරිම අස්වැන්නක් ලබා ගැනීමට අවශ්‍ය ජල සම්පාදනය, පොහොර යෙදීම සහ රැකවරණ උපදෙස් කරුණු වශයෙන් (Point by point) පැහැදිලි කරන්න.';
      } else if (currentLang == 'ta') {
        prompt = 'எனது பயிர் ($plant) ஆரோக்கியமானது என உறுதி செய்யப்பட்டுள்ளது. இதன் ஆரோக்கியத்தைப் பேணவும் அதிக விளைச்சலைப் பெறவும் தேவையான ஆலோசனைகளை விளக்கவும்.';
      } else {
        prompt = 'I scanned my crop leaf ($plant) and it was identified as healthy. Please provide point-by-point advice on optimal fertilizers, irrigation schedule, and preventive care to maximize healthy yield.';
      }
    } else {
      if (currentLang == 'si') {
        prompt = 'මම ශාක පත්‍රයක් ස්කෑන් කළ නමුත් එය නිවැරදිව හඳුනාගැනීමට අපොහොසත් විය. පැහැදිලි ඡායාරූපයක් ගෙන ශාක රෝග හඳුනාගැනීමට උපදෙස් ලබා දෙන්න.';
      } else if (currentLang == 'ta') {
        prompt = 'நான் ஒரு தாவர இலையை ஸ்கேன் செய்தேன், ஆனால் அதை சரியாக அடையாளம் காண முடியவில்லை. துல்லியமான நோய் கண்டறிதலுக்கு தெளிவான படம் எடுக்க சிறந்த வழிகள் யாவை?';
      } else {
        prompt = 'I scanned a plant leaf but the result was unrecognized. What are the best guidelines for taking clear diagnostic leaf photos and identifying plant issues accurately?';
      }
    }

    final String plantTitle;
    if (isUnrecognized) {
      plantTitle = currentLang == 'si'
          ? 'ශාක පරීක්ෂාව'
          : (currentLang == 'ta' ? 'பயிர் ஆய்வு' : 'Plant Diagnostic Scan');
    } else {
      plantTitle = isDiseased ? '$plant ($condition)' : '$plant (Healthy)';
    }

    context.push('/chat', extra: {
      'prompt': prompt,
      'imagePath': imagePath,
      'title': plantTitle,
      'cropType': plant,
    });
  }

  Future<void> _handleCapture(WidgetRef ref, BuildContext context, ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (context.mounted) {
          final currentLang = ref.read(localeProvider).languageCode;
          final permMsg = currentLang == 'si'
              ? 'කැමරාව භාවිතා කිරීමට අවසර අවශ්‍යයි.'
              : (currentLang == 'ta' ? 'கேமரா அனுமதி தேவை.' : 'Camera permission is required.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(permMsg),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
    await ref.read(scanControllerProvider.notifier).captureAndClassify(source);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Immersive dark background for this screen
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (state.imagePath != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
            ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/scan/history'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image (Real or Placeholder)
          Positioned.fill(
            child: state.imagePath != null
                ? Image.file(
                    File(state.imagePath!),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/leaf_placeholder.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Theme.of(context).colorScheme.primary,
                      child: const Center(
                        child: Icon(Icons.eco, size: 120, color: Colors.white24),
                      ),
                    ),
                  ),
          ),
          
          // Dark Overlay with clear focus area (only when idle)
          if (state.imagePath == null)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.6),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white, // This part is "punched out"
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // Focus Brackets (idle)
          if (state.imagePath == null)
            Center(
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            
          // Scanning Animation Layer
          if (state.isLoading)
            Positioned.fill(
              child: _ScanningAnimationOverlay(),
            ),
            
          // Bottom Sheet Controls or Results
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.76,
              ),
              padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _buildBottomPanel(context, ref, state),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticalStepTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(BuildContext context, WidgetRef ref, ScanState state) {
    final l10n = AppLocalizations.of(context)!;
    final currentLang = ref.watch(localeProvider).languageCode;

    if (state.isLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 16),
          Text(
            l10n.analyzingCrop,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.keepDeviceSteady,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    if (state.error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            l10n.analysisFailed,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            state.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
            child: Text(l10n.tryAgain),
          )
        ],
      );
    }

    if (state.imagePath != null && state.result != null) {
      final isUnrecognized = !state.result!.isPlant ||
          state.result!.confidence == 0 ||
          state.result!.label.contains('Unrecognized') ||
          state.result!.label.contains('හඳුනාගත නොහැක') ||
          state.result!.label.contains('නොවේ') ||
          state.result!.label.contains('அடையாளம்') ||
          state.result!.label.contains('கண்டறியப்படவில்லை');

      // 1. Dedicated, clean UI when image is NOT a plant (e.g. helmet, car, non-plant object)
      if (isUnrecognized) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                children: [
                  if (state.imagePath != null && File(state.imagePath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(state.imagePath!),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 36),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentLang == 'si'
                        ? 'ශාකයක් හෝ බෝගයක් හඳුනාගත නොහැක'
                        : (currentLang == 'ta' ? 'தாவரம் கண்டறியப்படவில்லை' : 'No Plant or Crop Detected'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.result!.treatmentPlan.isNotEmpty
                        ? state.result!.treatmentPlan
                        : (currentLang == 'si'
                            ? 'ඡායාරූපයෙහි ශාක පත්‍රයක් හෝ බෝගයක් හඳුනාගත නොහැක (උදා: හෙල්මට්, වාහන හෝ වෙනත් වස්තූන්). කරුණාකර සැබෑ ශාක පත්‍රයක් ආලෝකය සහිතව ඡායාරූපගත කර නැවත ස්කෑන් කරන්න.'
                            : (currentLang == 'ta'
                                ? 'இந்த படத்தில் தாவர இலை கண்டறியப்படவில்லை. தயவுசெய்து உண்மையான பயிர் இலையை படம் எடுத்து மீண்டும் ஸ்கேன் செய்யவும்.'
                                : 'No plant leaf detected in this photo (e.g., helmet, furniture, or non-plant item). Please take a well-lit photo of an actual plant leaf and rescan.')),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                currentLang == 'si'
                    ? 'නැවත ස්කෑන් කරන්න (Rescan)'
                    : (currentLang == 'ta' ? 'மீண்டும் ஸ்கேன் செய்' : 'Rescan / Retake Photo'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _handleCapture(ref, context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(
                currentLang == 'si' ? 'කැමරාවෙන් අලුත් ඡායාරූපයක් ගන්න' : 'Take New Photo with Camera',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        );
      }

      // 2. Real Plant Detected: Render Comprehensive Diagnostic Details
      final isDiseased = !state.result!.isHealthy;
      final isHealthy = state.result!.isHealthy;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Visual Scanned Photo & Diagnosis Hero Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDiseased
                    ? Colors.redAccent.withValues(alpha: 0.35)
                    : (isHealthy ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35) : Colors.orange.withValues(alpha: 0.35)),
              ),
            ),
            child: Row(
              children: [
                if (state.imagePath != null && File(state.imagePath!).existsSync())
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(state.imagePath!),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDiseased ? Colors.redAccent : (isHealthy ? Colors.green : Colors.orange),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDiseased ? Icons.warning_rounded : (isHealthy ? Icons.eco : Icons.help_outline),
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDiseased
                              ? Colors.redAccent.withValues(alpha: 0.15)
                              : (isHealthy ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isUnrecognized
                              ? (currentLang == 'si' ? 'අවධානය: ශාක පත්‍රයක් නොවේ' : (currentLang == 'ta' ? 'அடையாளம் காணப்படவில்லை' : 'Unrecognized Image'))
                              : (isDiseased
                                  ? (currentLang == 'si' ? '⚠️ රෝගී තත්ත්වයක් හඳුනාගෙන ඇත' : (currentLang == 'ta' ? '⚠️ நோய் கண்டறியப்பட்டது' : '⚠️ Disease Detected'))
                                  : (currentLang == 'si' ? '🌿 නිරෝගී ශාක පත්‍රයකි' : (currentLang == 'ta' ? '🌿 ஆரோக்கியமான பயிர்' : '🌿 Healthy Crop'))),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDiseased ? Colors.redAccent : (isHealthy ? Colors.green : Colors.orange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isDiseased
                            ? (state.result!.diseaseName.isNotEmpty ? state.result!.diseaseName : state.result!.label)
                            : state.result!.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isUnrecognized ? Colors.orange : (isDiseased ? Colors.redAccent : Theme.of(context).colorScheme.primary),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.confidence((state.result!.confidence * 100).toStringAsFixed(1)),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                          if (isDiseased && state.result!.severity.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n.severity(state.result!.severity),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Plant Profile Card (ශාකයේ නම, ගහේ වර්ගය, විද්‍යාත්මක නම)
          if (!isUnrecognized) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nature_people_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        currentLang == 'si'
                            ? 'ශාකයේ සම්පූර්ණ විස්තරය (Plant Profile)'
                            : (currentLang == 'ta' ? 'பயிர் விவரக்குறிப்பு' : 'Plant & Crop Profile'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentLang == 'si' ? 'ශාකයේ නම' : (currentLang == 'ta' ? 'பயிரின் பெயர்' : 'Plant Name'),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              state.result!.plantName.isNotEmpty ? state.result!.plantName : state.result!.label,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentLang == 'si' ? 'ගහේ / බෝග වර්ගය' : (currentLang == 'ta' ? 'பயிர் வகை' : 'Crop Category'),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              state.result!.cropType.isNotEmpty
                                  ? state.result!.cropType
                                  : (currentLang == 'si' ? 'කෘෂිකාර්මික බෝග' : 'Crop'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (state.result!.botanicalName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.menu_book_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${currentLang == 'si' ? 'උද්භිද විද්‍යාත්මක නම' : 'Botanical Name'}: ${state.result!.botanicalName}',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Symptoms Card when Symptoms are detected
          if (isDiseased && state.result!.symptoms.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.search_outlined, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        currentLang == 'si'
                            ? 'නිරීක්ෂණය වූ රෝග ලක්ෂණ'
                            : (currentLang == 'ta' ? 'கண்டறியப்பட்ட அறிகுறிகள்' : 'Observed Disease Symptoms'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.result!.symptoms,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Practical Action Guide when Diseased
          if (isDiseased) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        currentLang == 'si'
                            ? 'ප්‍රායෝගික ක්ෂේත්‍ර ප්‍රතිකාර සැලැස්ම'
                            : (currentLang == 'ta' ? 'நடைமுறை கள சிகிச்சை திட்டம்' : 'Practical Field Treatment Plan'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPracticalStepTile(
                    context,
                    icon: Icons.content_cut,
                    iconColor: Colors.orange,
                    title: currentLang == 'si' ? '1. හදිසි ක්ෂේත්‍ර පියවර සහ හුදකලා කිරීම' : (currentLang == 'ta' ? '1. அவசர கள நடவடிக்கைகள்' : '1. Immediate Field Action'),
                    desc: state.result!.immediateActions.isNotEmpty
                        ? state.result!.immediateActions
                        : (currentLang == 'si'
                            ? 'ආසාදිත කොළ සහ අතු වහාම කපා ඉවත් කර වගා බිමෙන් ඉවතට ගෙන විනාශ කරන්න.'
                            : (currentLang == 'ta' ? 'பாதிக்கப்பட்ட இலைகளை வெட்டி அகற்றி தோட்டத்திலிருந்து வெளியேற்றவும்.' : 'Prune affected leaves immediately and dispose of them far from the field.')),
                  ),
                  const SizedBox(height: 8),
                  _buildPracticalStepTile(
                    context,
                    icon: Icons.eco,
                    iconColor: Colors.green,
                    title: currentLang == 'si' ? '2. කාබනික ස්වාභාවික පිළියම් සහ මාත්‍රා' : (currentLang == 'ta' ? '2. இயற்கை தீர்வுகள் மற்றும் அளவுகள்' : '2. Organic Remedies & Dosages'),
                    desc: state.result!.organicRemedies.isNotEmpty
                        ? state.result!.organicRemedies
                        : (currentLang == 'si'
                            ? 'කොහොඹ තෙල් මිලිලීටර් 5ක් සබන් වතුර ලීටරයකට මිශ්‍ර කර දින 5-7 කට වරක් කොළ වලට ඉසින්න.'
                            : (currentLang == 'ta' ? 'வேப்பெண்ணெய் 5ml-ஐ சோப்பு கலந்த தண்ணீரில் கலந்து 5-7 நாட்களுக்கு ஒருமுறை தெளிக்கவும்.' : 'Mix 5ml neem oil with a drop of liquid soap per liter of water and spray every 5-7 days.')),
                  ),
                  const SizedBox(height: 8),
                  _buildPracticalStepTile(
                    context,
                    icon: Icons.science,
                    iconColor: Colors.blueAccent,
                    title: currentLang == 'si' ? '3. රසායනික පාලනය සහ නිර්දේශිත මාත්‍රා' : (currentLang == 'ta' ? '3. இரசாயன கட்டுப்பாடு மற்றும் அளவுகள்' : '3. Chemical Controls & Exact Dosages'),
                    desc: state.result!.chemicalRemedies.isNotEmpty
                        ? state.result!.chemicalRemedies
                        : (state.result!.treatmentPlan.isNotEmpty
                            ? state.result!.treatmentPlan
                            : (currentLang == 'si'
                                ? 'ප්‍රාදේශීය කෘෂිකර්ම උපදෙස් අනුව නිර්දේශිත දිලීර හෝ කෘමි නාශක යොදන්න.'
                                : (currentLang == 'ta' ? 'பரிந்துரைக்கப்பட்ட பூஞ்சைக் கொல்லி அல்லது மருந்தைப் பயன்படுத்தவும்.' : 'Apply recommended fungicide or pesticide according to local guidance.'))),
                  ),
                  const SizedBox(height: 8),
                  _buildPracticalStepTile(
                    context,
                    icon: Icons.water_drop,
                    iconColor: Colors.lightBlue,
                    title: currentLang == 'si' ? '4. ජල සම්පාදනය සහ වැළැක්වීමේ පියවර' : (currentLang == 'ta' ? '4. நீர்ப்பாசனம் மற்றும் தடுப்பு வழிகள்' : '4. Irrigation & Long-Term Prevention'),
                    desc: state.result!.preventiveTips.isNotEmpty
                        ? state.result!.preventiveTips
                        : (currentLang == 'si'
                            ? 'කොළ මතට ජලය නොවැටෙන සේ ශාකයේ මුල් පාමුලට පමණක් උදෑසන කාලයේ ජලය සපයන්න.'
                            : (currentLang == 'ta' ? 'இலைகள் நனையாமல் காலையில் வேருக்கு மட்டும் தண்ணீர் பாய்ச்சவும்.' : 'Avoid wetting foliage; water strictly at root level during early morning.')),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => _askAiAboutScan(context, ref, state.result!, state.imagePath),
                    icon: const Icon(Icons.psychology, size: 20),
                    label: Text(
                      currentLang == 'si'
                          ? 'සවිස්තර ප්‍රතිකාර සැලැස්ම AI වෙතින් විමසන්න'
                          : (currentLang == 'ta' ? 'முழு சிகிச்சை திட்டத்தை AI-யிடம் கேட்கவும்' : 'Ask AI for In-Depth Details (Point-by-Point)'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Practical Maintenance Guide when Healthy
          if (isHealthy) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        currentLang == 'si'
                            ? 'නිරෝගී අස්වැන්නක් සඳහා ප්‍රායෝගික පියවර'
                            : (currentLang == 'ta' ? 'ஆரோக்கியமான விளைச்சலுக்கான நடைமுறை வழிகள்' : 'Practical Maintenance & Care Guide'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPracticalStepTile(
                    context,
                    icon: Icons.water_drop,
                    iconColor: Colors.blueAccent,
                    title: currentLang == 'si' ? '1. ක්‍රමවත් ජල සම්පාදනය' : (currentLang == 'ta' ? '1. சரியான நீர்ப்பாசனம்' : '1. Regular Irrigation'),
                    desc: currentLang == 'si'
                        ? 'පසෙහි තෙතමනය පරීක්ෂා කර නියමිත වේලාවට මුල් පාමුලට ජලය සපයන්න.'
                        : (currentLang == 'ta' ? 'மண்ணின் ஈரப்பதத்தைப் பார்த்து வேருக்கு மட்டும் தண்ணீர் பாய்ச்சவும்.' : 'Check soil moisture and irrigate regularly at root level.'),
                  ),
                  const SizedBox(height: 8),
                  _buildPracticalStepTile(
                    context,
                    icon: Icons.eco,
                    iconColor: Colors.green,
                    title: currentLang == 'si' ? '2. කාබනික පෝෂණය හා පොහොර' : (currentLang == 'ta' ? '2. இயற்கை ஊட்டச்சத்து மற்றும் உரம்' : '2. Organic Nutrition'),
                    desc: currentLang == 'si'
                        ? 'කොම්පෝස්ට් හෝ කාබනික දියර පොහොර ක්‍රමානුකූලව යොදා පෝෂණය සුරකින්න.'
                        : (currentLang == 'ta' ? 'கம்போஸ்ட் அல்லது இயற்கை உரங்களை சரியான இடைவெளியில் இடவும்.' : 'Apply balanced compost or organic liquid fertilizer regularly.'),
                  ),
                  const SizedBox(height: 8),
                  _buildPracticalStepTile(
                    context,
                    icon: Icons.shield_outlined,
                    iconColor: Colors.amber,
                    title: currentLang == 'si' ? '3. රෝග නිවාරණ පරීක්ෂාව' : (currentLang == 'ta' ? '3. தடுப்பு கண்காணிப்பு' : '3. Preventive Monitoring'),
                    desc: state.result!.treatmentPlan.isNotEmpty
                        ? state.result!.treatmentPlan
                        : (currentLang == 'si'
                            ? 'සතියකට වරක් කොළ යටි පැත්ත පරීක්ෂා කර පළිබෝධ අවදානම් වළක්වා ගන්න.'
                            : (currentLang == 'ta' ? 'வாரத்திற்கு ஒருமுறை இலையின் அடிப்பகுதியை ஆய்வு செய்யவும்.' : 'Inspect undersides of leaves weekly to prevent pest attacks early.')),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _askAiAboutScan(context, ref, state.result!, state.imagePath),
                    icon: const Icon(Icons.smart_toy_outlined, size: 18),
                    label: Text(
                      currentLang == 'si'
                          ? 'අස්වැන්න වැඩි කරගැනීමේ උපදෙස් AI වෙතින් විමසන්න'
                          : (currentLang == 'ta' ? 'விளைச்சல் பெருக்க ஆலோசனைகளை AI-யிடம் கேட்கவும்' : 'Ask AI for Care & Yield Tips'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: state.isSaved
                ? null
                : () {
                    ref.read(scanControllerProvider.notifier).saveResult(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.savedToOfflineDb),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
            icon: Icon(state.isSaved ? Icons.check : Icons.save),
            label: Text(state.isSaved ? l10n.saved : l10n.saveResult),
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isSaved ? Colors.grey : Theme.of(context).colorScheme.secondary,
              minimumSize: const Size(double.infinity, 54),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _askAiAboutScan(context, ref, state.result!, state.imagePath),
            icon: const Icon(Icons.forum_outlined),
            label: Text(
              currentLang == 'si'
                  ? 'මෙම ස්කෑන් පරීක්ෂාව ගැන AgriAI සමග කතාබස් කරන්න'
                  : (currentLang == 'ta' ? 'இந்த ஆய்வு பற்றி AgriAI உடன் பேசவும்' : 'Chat with AgriAI about this scan'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              currentLang == 'si'
                  ? 'වෙනත් බෝගයක් ස්කෑන් කරන්න (Rescan)'
                  : (currentLang == 'ta' ? 'வேறு பயிரை ஸ்கேன் செய்யவும்' : 'Scan Another Crop / Rescan'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      );
    }

    // Default Idle State (Bottom Panel)
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.identifyCropDisease,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.scanInstruction,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleCapture(ref, context, ImageSource.gallery),
                icon: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                label: Text(l10n.gallery, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleCapture(ref, context, ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(l10n.scanNow),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _ScanningAnimationOverlay extends StatefulWidget {
  @override
  State<_ScanningAnimationOverlay> createState() => _ScanningAnimationOverlayState();
}

class _ScanningAnimationOverlayState extends State<_ScanningAnimationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Colors.black.withValues(alpha: 0.3)),
            Positioned(
              top: MediaQuery.of(context).size.height * _animation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2),
                    BoxShadow(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
