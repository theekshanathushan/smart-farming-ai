import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/ai_agent/presentation/chat_screen.dart';

import '../../features/camera_scan/presentation/camera_scan_screen.dart';
import '../../features/camera_scan/presentation/scan_history_screen.dart';
import '../../features/knowledge_base/presentation/knowledge_base_screen.dart';
import '../../features/knowledge_base/presentation/pest_detail_screen.dart';
import '../../features/irrigation/presentation/irrigation_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

import '../../features/home/presentation/home_screen.dart';

import '../../features/welcome/presentation/welcome_screen.dart';
import '../../features/auth/presentation/language_selection_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/market/presentation/market_screen.dart';
import '../../features/farm/presentation/farm_screen.dart';
import '../../features/farm/presentation/add_crop_screen.dart';
import '../../features/ledger/presentation/ledger_screen.dart';
import '../../features/ledger/presentation/add_transaction_screen.dart';
import '../../features/fertilizer/presentation/fertilizer_calc_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/ecommerce/presentation/marketplace_screen.dart';
import '../../features/ecommerce/presentation/add_harvest_screen.dart';
import 'main_layout.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Only rebuild the router when login state changes, not on every auth status change.
  final isLoggedIn = ref.watch(authProvider.select((state) => state.isLoggedIn));

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/' || 
                          state.matchedLocation == '/welcome' ||
                          state.matchedLocation == '/auth' || 
                          state.matchedLocation == '/verify-otp';

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }
      if (!isLoggedIn && !isAuthRoute) {
        return '/';
      }
      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/farm',
                builder: (context, state) => const FarmScreen(),
                routes: [
                  GoRoute(
                    path: 'add-crop',
                    builder: (context, state) => const AddCropScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                builder: (context, state) => const CameraScanScreen(),
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const ScanHistoryScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/market',
                builder: (context, state) => const MarketScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          String? initialMessage;
          String? initialImagePath;
          String? sessionId;

          if (state.extra is String) {
            initialMessage = state.extra as String;
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            initialMessage = map['prompt'] as String? ?? map['message'] as String?;
            initialImagePath = map['imagePath'] as String?;
            sessionId = map['sessionId'] as String?;
          }

          return AiChatScreen(
            key: ValueKey(sessionId ?? initialMessage ?? 'chat_${DateTime.now().millisecondsSinceEpoch}'),
            initialMessage: initialMessage,
            initialImagePath: initialImagePath,
            initialSessionId: sessionId,
          );
        },
      ),
      GoRoute(
        path: '/ledger',
        builder: (context, state) => const LedgerScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddTransactionScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/fertilizer',
        builder: (context, state) => const FertilizerCalcScreen(),
      ),
      GoRoute(
        path: '/guide',
        builder: (context, state) => const KnowledgeBaseScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PestDetailScreen(pestId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/irrigation',
        builder: (context, state) => const IrrigationScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/ecommerce',
        builder: (context, state) => const MarketplaceScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddHarvestScreen(),
          ),
        ],
      ),
    ],
  );
});
