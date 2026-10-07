import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_ai/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Clear previous states
      ref.read(authProvider.notifier).resetState();
      
      final phone = _phoneController.text.trim();
      final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null;
      
      ref.read(authProvider.notifier).sendOTP(phone, name: name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Listen for state changes to navigate or show errors
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
      } else if (next.status == AuthStateStatus.otpSent) {
        context.push('/verify-otp');
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStateStatus.loading;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final toggleBg = isDark ? const Color(0xFF16222F) : Colors.grey.shade200;
    final toggleActiveBg = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? l10n.welcomeBack : l10n.createAccount,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? l10n.enterPhoneToContinue
                      : l10n.registerToAccess,
                  style: TextStyle(
                    fontSize: 15,
                    color: subtextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Toggle Login / Register
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: toggleBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLogin = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _isLogin ? toggleActiveBg : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.login,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _isLogin ? Colors.white : subtextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLogin = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !_isLogin ? toggleActiveBg : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.register,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: !_isLogin ? Colors.white : subtextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    context,
                    _isLogin ? '${l10n.fullNameOrFarmName} (ඔබගේ නම)' : l10n.fullNameOrFarmName,
                    Icons.person_outline,
                  ),
                  style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (!_isLogin && (value == null || value.trim().isEmpty)) {
                      return l10n.enterNameValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone number field
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration(context, l10n.phoneNumber, Icons.phone_outlined),
                  style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterPhoneValidation;
                    }
                    if (value.trim().length < 9) {
                      return l10n.enterValidPhoneValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Submit button
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? const Color(0xFF334155) : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isLogin ? l10n.sendOtp : l10n.registerAndSendOtp,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      l10n.sendingOtp,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
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

  // Extracted input decoration for high contrast & theme adaptivity
  InputDecoration _inputDecoration(BuildContext context, String hint, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillBg = isDark ? const Color(0xFF16222F) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final iconCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final hintCol = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final primaryCol = Theme.of(context).colorScheme.primary;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintCol, fontSize: 15),
      prefixIcon: Icon(icon, color: iconCol),
      filled: true,
      fillColor: fillBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderCol, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryCol, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }
}
