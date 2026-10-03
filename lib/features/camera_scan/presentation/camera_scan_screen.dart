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

  void _askAiAboutScan(BuildContext context, WidgetRef ref, ClassifierResult result) {
    final currentLang = ref.read(localeProvider).languageCode;
    final isDiseased = !result.isHealthy && !result.label.contains('Unrecognized');
    final isHealthy = result.isHealthy && !result.label.contains('Unrecognized');
    
    String prompt;
    if (isDiseased) {
      final condition = result.diseaseName.isNotEmpty ? result.diseaseName : result.label;
      if (currentLang == 'si') {
        prompt = 'මගේ බෝගයේ කොළ ස්කෑන් කළ විට හඳුනාගත් රෝග විස්තර පහත දැක්වේ:\n\n'
            '• හඳුනාගත් රෝගය: $condition\n'
            '• බරපතලකම (Severity): ${result.severity}\n'
            '• ආකෘති විශ්වාසනීයත්වය: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
            '${result.treatmentPlan.isNotEmpty ? '• මූලික උපදෙස්: ${result.treatmentPlan}\n' : ''}\n'
            'කරුණාකර මෙම රෝගය සුව කිරීමට අවශ්‍ය සවිස්තරාත්මක ප්‍රතිකාර, ස්වාභාවික හා කාබනික ක්‍රම, සහ නැවත බෝවීම වැළැක්වීමේ පියවර කරුණු වශයෙන් (Point by point) පැහැදිලිව ලබා දෙන්න.';
      } else if (currentLang == 'ta') {
        prompt = 'எனது பயிரின் இலை ஸ்கேன் செய்யப்பட்டதன் முடிவுகள்:\n\n'
            '• கண்டறியப்பட்ட நோய்: $condition\n'
            '• தீவிரம்: ${result.severity}\n'
            '• மாதிரி துல்லியம்: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
            '${result.treatmentPlan.isNotEmpty ? '• முதற்கட்ட சிகிச்சை: ${result.treatmentPlan}\n' : ''}\n'
            'தயவுசெய்து இந்த நோயைக் கட்டுப்படுத்த இயற்கை முறைகள், மருந்து பரிந்துரைகள் மற்றும் தடுப்பு வழிகளை குறிப்புகளாக (Point by point) தெளிவாக விளக்குங்கள்.';
      } else {
        prompt = 'I scanned a crop leaf and the diagnosis returned the following details:\n\n'
            '• Crop Condition / Disease: $condition\n'
            '• Severity: ${result.severity}\n'
            '• Model Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
            '${result.treatmentPlan.isNotEmpty ? '• Preliminary Treatment: ${result.treatmentPlan}\n' : ''}\n'
            'Please provide comprehensive, point-by-point advice covering:\n'
            '1. Diagnosis & Key Symptoms\n'
            '2. Causes & Environmental Factors\n'
            '3. Immediate Organic & Natural Remedies\n'
            '4. Chemical Controls or Fertilizer Adjustments with recommended dosages\n'
            '5. Long-term Prevention & Field Care';
      }
    } else if (isHealthy) {
      if (currentLang == 'si') {
        prompt = 'මගේ බෝගය නිරෝගී (${result.label}) ලෙස ස්කෑන් කර ඇත. මෙම බෝගයේ නිරෝගීභාවය රැකගෙන උපරිම අස්වැන්නක් ලබා ගැනීමට අවශ්‍ය ජල සම්පාදනය, පොහොර යෙදීම සහ රැකවරණ උපදෙස් කරුණු වශයෙන් (Point by point) පැහැදිලි කරන්න.';
      } else if (currentLang == 'ta') {
        prompt = 'எனது பயிர் ஆரோக்கியமானது (${result.label}) என உறுதி செய்யப்பட்டுள்ளது. இதன் ஆரோக்கியத்தைப் பேணவும் அதிக விளைச்சலைப் பெறவும் தேவையான ஆலோசனைகளை குறிப்புகளாக (Point by point) விளக்கவும்.';
      } else {
        prompt = 'I scanned my crop leaf and it was identified as healthy (${result.label}). Please provide point-by-point advice on optimal fertilizers, irrigation schedule, and preventive care to maximize healthy yield.';
      }
    } else {
      prompt = 'I scanned a plant leaf but the result was unrecognized. What are the best guidelines for taking clear diagnostic leaf photos and identifying plant issues accurately?';
    }

    context.push('/chat', extra: prompt);
  }

  Future<void> _handleCapture(WidgetRef ref, BuildContext context, ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Camera permission is required.'),
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
                  Colors.black.withOpacity(0.6),
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
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
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
              padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 48),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildBottomPanel(context, ref, state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, WidgetRef ref, ScanState state) {
    final l10n = AppLocalizations.of(context)!;
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
      final isUnrecognized = state.result!.label.contains('Unrecognized');
      final isDiseased = !state.result!.isHealthy && !isUnrecognized;
      final isHealthy = state.result!.isHealthy && !isUnrecognized;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isUnrecognized ? l10n.scanResult : (isDiseased ? l10n.attentionNeeded : l10n.greatNews),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isDiseased ? (state.result!.diseaseName.isNotEmpty ? state.result!.diseaseName : state.result!.label) : state.result!.label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnrecognized ? Colors.orange : (isDiseased ? Colors.redAccent : Theme.of(context).colorScheme.primary),
              fontSize: isUnrecognized ? 20 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.confidence((state.result!.confidence * 100).toStringAsFixed(1)),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                if (isDiseased && state.result!.severity.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l10n.severity(state.result!.severity),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ),
          if (isDiseased) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Text('Treatment Plan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.result!.treatmentPlan.isNotEmpty 
                      ? state.result!.treatmentPlan 
                      : 'Please consult with a local agricultural expert for specific treatments.', 
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => _askAiAboutScan(context, ref, state.result!),
                    icon: const Icon(Icons.psychology, size: 20),
                    label: const Text('Ask AI for In-Depth Details (Point-by-Point)', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (isHealthy) ...[
             const SizedBox(height: 24),
             Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.result!.treatmentPlan.isNotEmpty 
                          ? state.result!.treatmentPlan 
                          : 'Your crop looks perfectly healthy! Keep up the good irrigation and fertilizer routine.', 
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _askAiAboutScan(context, ref, state.result!),
                    icon: const Icon(Icons.smart_toy_outlined, size: 18),
                    label: const Text('Ask AI for Care & Yield Tips'),
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

          const SizedBox(height: 24),
          if (isUnrecognized)
            ElevatedButton(
              onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(l10n.tryAgain, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else ...[
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
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _askAiAboutScan(context, ref, state.result!),
              icon: const Icon(Icons.forum_outlined),
              label: const Text('Chat with AgriAI about this scan', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
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
            Container(color: Colors.black.withOpacity(0.3)),
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
