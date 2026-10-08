import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:agri_ai/l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  // Ensure widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env: $e");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAnalytics.instance;
  } catch (e) {
    debugPrint("Warning: Firebase initialization error: $e");
  }

  // Pre-load session for instantaneous startup and DB resolution
  AuthState? initialAuthState;
  try {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userPhone = prefs.getString('userPhone');
    if (isLoggedIn && userPhone != null && userPhone.isNotEmpty) {
      final name = prefs.getString('registered_user_name_$userPhone') ?? prefs.getString('userName');
      String? profileImage = prefs.getString('user_profile_photo_$userPhone') ?? prefs.getString('profileImagePath');
      if (profileImage != null && !File(profileImage).existsSync()) {
        profileImage = null;
      }
      initialAuthState = AuthState(
        isLoggedIn: true,
        phoneNumber: userPhone,
        name: name,
        profileImagePath: profileImage,
      );
    }
  } catch (e) {
    debugPrint("Warning: Session preload error: $e");
  }

  runApp(
    ProviderScope(
      overrides: [
        if (initialAuthState != null)
          authProvider.overrideWith((ref) => AuthNotifier(initialAuthState)),
      ],
      child: const AgriAIApp(),
    ),
  );
}

class AgriAIApp extends ConsumerWidget {
  const AgriAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'AgriAI',
      theme: AppTheme.getLightTheme(locale.languageCode),
      darkTheme: AppTheme.getDarkTheme(locale.languageCode),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}