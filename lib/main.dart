import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/local_db/app_database.dart';
import 'core/theme/app_theme.dart';

// Provide the database globally
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

void main() async {
  // Ensure widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the local Drift database instance
  final database = AppDatabase();
  
  // Additional initializations (e.g., TFLite) can go here
  
  runApp(
    ProviderScope(
      overrides: [
        // Override the provider to use the initialized instance
        databaseProvider.overrideWithValue(database),
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
    
    return MaterialApp.router(
      title: 'AgriAI',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
