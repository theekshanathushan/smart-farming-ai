import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/providers/locale_provider.dart';

final scanHistoryProvider = FutureProvider<List<ScanResult>>((ref) {
  return ref.watch(databaseProvider).getAllScanResults();
});

class ScanHistoryScreen extends ConsumerWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Center(
                    child: Text(
                      "No scans found in history.", 
                      style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF475569), fontSize: 15),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _buildHistoryCard(context, ref, item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WidgetRef ref, ScanResult item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final confidencePercent = (item.confidence * 100).toStringAsFixed(1);
    
    return InkWell(
      onTap: () {
        _showImageDialog(context, ref, item);
      },
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.file(
                  File(item.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.broken_image, 
                    color: isDark ? Colors.white54 : Colors.black38, 
                    size: 50,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.predictedLabel,
                    style: TextStyle(
                      color: textColor, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.25 : 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$confidencePercent% Confidence',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B5E20),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateFormat.format(item.timestamp),
                    style: TextStyle(color: subtextColor, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, WidgetRef ref, ScanResult item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: InteractiveViewer(
                    child: Image.file(
                      File(item.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.broken_image, color: Colors.white54, size: 60),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.predictedLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(item.confidence * 100).toStringAsFixed(1)}% Confidence',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM dd, yyyy').format(item.timestamp),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        final currentLang = ref.read(localeProvider).languageCode;
                        String prompt;
                        if (currentLang == 'si') {
                          prompt = 'පෙර ස්කෑන් කරන ලද බෝගයේ තොරතුරු:\n'
                              '• බෝගය / රෝගය: ${item.predictedLabel}\n'
                              '• විශ්වාසනීයත්වය: ${(item.confidence * 100).toStringAsFixed(1)}%\n\n'
                              'කරුණාකර මෙම බෝගය රැකබලා ගැනීමට හෝ ප්‍රතිකාර කිරීමට අවශ්‍ය උපදෙස් කරුණු වශයෙන් (Point by point) සවිස්තරාත්මකව ලබා දෙන්න.';
                        } else if (currentLang == 'ta') {
                          prompt = 'முந்தைய ஸ்கேன் செய்யப்பட்ட பயிர் விபரம்:\n'
                              '• பயிர் / நோய்: ${item.predictedLabel}\n'
                              '• துல்லியம்: ${(item.confidence * 100).toStringAsFixed(1)}%\n\n'
                              'தயவுசெய்து இந்த பயிருக்கான விரிவான பராமரிப்பு அல்லது சிகிச்சை வழிகாட்டல்களை குறிப்புகளாக (Point by point) விளக்கவும்.';
                        } else {
                          prompt = 'Details from a previous scan in my history:\n'
                              '• Crop / Diagnosis: ${item.predictedLabel}\n'
                              '• Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%\n\n'
                              'Please provide a detailed, point-by-point guide on treatment, care routine, and prevention tips for this diagnosis.';
                        }
                        context.push('/chat', extra: {
                          'prompt': prompt,
                          'imagePath': item.imagePath,
                        });
                      },
                      icon: const Icon(Icons.psychology, size: 20),
                      label: const Text('Ask AgriAI about this scan', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
