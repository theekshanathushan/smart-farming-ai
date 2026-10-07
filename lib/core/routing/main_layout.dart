import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_ai/l10n/app_localizations.dart';
import '../../features/camera_scan/presentation/scan_controller.dart';
import '../providers/locale_provider.dart';

class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: theme.colorScheme.surface,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.2),
            labelTextStyle: WidgetStateProperty.all(
              theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.grass_outlined),
                selectedIcon: const Icon(Icons.grass_rounded),
                label: l10n.navFarm,
              ),
              NavigationDestination(
                icon: const Icon(Icons.camera_alt_outlined),
                selectedIcon: const Icon(Icons.camera_alt_rounded),
                label: l10n.navScan,
              ),
              NavigationDestination(
                icon: const Icon(Icons.storefront_outlined),
                selectedIcon: const Icon(Icons.storefront_rounded),
                label: l10n.navMarket,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final scanState = ref.read(scanControllerProvider);
          if (navigationShell.currentIndex == 2 &&
              scanState.result != null &&
              !scanState.result!.label.contains('Unrecognized')) {
            final result = scanState.result!;
            final currentLang = ref.read(localeProvider).languageCode;
            final isDiseased = !result.isHealthy;
            final condition = result.diseaseName.isNotEmpty ? result.diseaseName : result.label;
            String prompt;
            if (isDiseased) {
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
                    'Please provide comprehensive, point-by-point advice covering treatment, remedies, and long-term care.';
              }
            } else {
              if (currentLang == 'si') {
                prompt = 'මගේ බෝගය නිරෝගී (${result.label}) ලෙස ස්කෑන් කර ඇත. මෙම බෝගයේ නිරෝගීභාවය රැකගෙන උපරිම අස්වැන්නක් ලබා ගැනීමට අවශ්‍ය ජල සම්පාදනය, පොහොර යෙදීම සහ රැකවරණ උපදෙස් කරුණු වශයෙන් (Point by point) පැහැදිලි කරන්න.';
              } else {
                prompt = 'I scanned my crop leaf and it was identified as healthy (${result.label}). Please provide point-by-point advice on optimal fertilizers, irrigation schedule, and preventive care to maximize healthy yield.';
              }
            }
            final plantTitle = result.label.contains('Unrecognized')
                ? 'Plant Diagnostic Scan'
                : (result.diseaseName.isNotEmpty && !result.label.toLowerCase().contains(result.diseaseName.toLowerCase())
                    ? '${result.label} ($condition)'
                    : result.label);

            context.push('/chat', extra: {
              'prompt': prompt,
              'imagePath': scanState.imagePath,
              'title': plantTitle,
              'cropType': plantTitle,
            });
          } else {
            context.push('/chat');
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
    );
  }
}
