import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          color: Colors.white.withOpacity(0.85), // Overlay for readability
          child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.language,
                size: 80,
                color: Colors.green[800],
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Agri AI',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select your language\nකරුණාකර ඔබගේ භාෂාව තෝරන්න',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              _LanguageButton(
                title: 'English',
                onPressed: () {
                  context.push('/auth');
                },
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                title: 'සිංහල (Sinhala)',
                onPressed: () {
                  context.push('/auth');
                },
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                title: 'தமிழ் (Tamil)',
                onPressed: () {
                  context.push('/auth');
                },
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
  final VoidCallback onPressed;

  const _LanguageButton({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black87, width: 2), // Thick border for visibility
        padding: const EdgeInsets.symmetric(vertical: 20), // Minimum 48dp height (20 padding top/bottom + text = easily > 48dp)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
