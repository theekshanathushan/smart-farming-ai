import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).verifyOTP(_otpController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes (success / error)
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStateStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (next.status == AuthStateStatus.success) {
        // Navigate to Home upon success
        context.go('/home');
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStateStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Verify Number',
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.message_rounded,
                  size: 64,
                  color: Colors.black87,
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter OTP',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a 6-digit code to\n${authState.phoneNumber ?? "your number"}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Field
                TextFormField(
                  controller: _otpController,
                  decoration: _inputDecoration('6-digit OTP', Icons.security),
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, color: Colors.black87, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().length != 6) {
                      return 'Please enter the 6-digit OTP';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Verify button
                ElevatedButton(
                  onPressed: isLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 20), // Height > 48dp
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'Verify OTP',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Resend OTP button
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          // Resend logic
                          if (authState.phoneNumber != null) {
                            ref.read(authProvider.notifier).sendOTP(
                                  authState.phoneNumber!,
                                  name: authState.name,
                                );
                          }
                        },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), // Large touch target
                  ),
                  child: Text(
                    'Didn\'t receive code? Resend',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extracted input decoration for thick borders and high contrast
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54, letterSpacing: 0, fontSize: 16, fontWeight: FontWeight.normal),
      counterText: '', // Hide max length counter
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Large touch target
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black87, width: 2), // Thick border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[700]!, width: 3), // Thicker when focused
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[700]!, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[700]!, width: 3),
      ),
    );
  }
}
