import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/ai_agent/presentation/chat_screen.dart';

import '../../features/camera_scan/presentation/camera_scan_screen.dart';

import '../../features/home/presentation/home_screen.dart';

import '../../features/auth/presentation/language_selection_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/market/presentation/market_screen.dart';
import '../../features/farm/presentation/farm_screen.dart';
import '../../features/farm/presentation/add_crop_screen.dart';
import '../../features/ledger/presentation/ledger_screen.dart';
import '../../features/ledger/presentation/add_transaction_screen.dart';
import '../../features/fertilizer/presentation/fertilizer_calc_screen.dart';
import 'main_layout.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LanguageSelectionScreen(),
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
        builder: (context, state) => const AiChatScreen(),
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
    ],
  );
});
