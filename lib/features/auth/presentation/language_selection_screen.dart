import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/locale_provider.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  void _onLanguageSelected(BuildContext context, WidgetRef ref, String langCode) async {
    await ref.read(localeProvider.notifier).setLocale(Locale(langCode));
    if (context.mounted) {
      context.push('/welcome');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome to Agri AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please select your language\nකරුණාකර ඔබගේ භාෂාව තෝරන්න\nஉங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _LanguageButton(
                    title: 'English',
                    textStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    onPressed: () => _onLanguageSelected(context, ref, 'en'),
                  ),
                  const SizedBox(height: 16),
                  _LanguageButton(
                    title: 'සිංහල (Sinhala)',
                    textStyle: GoogleFonts.notoSansSinhala(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    onPressed: () => _onLanguageSelected(context, ref, 'si'),
                  ),
                  const SizedBox(height: 16),
                  _LanguageButton(
                    title: 'தமிழ் (Tamil)',
                    textStyle: GoogleFonts.notoSansTamil(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    onPressed: () => _onLanguageSelected(context, ref, 'ta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const _LanguageButton({
    required this.title,
    required this.textStyle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        title,
        style: textStyle,
      ),
    );
  }
}
