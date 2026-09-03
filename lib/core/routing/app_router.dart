import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/ai_agent/presentation/chat_screen.dart';

import '../../features/camera_scan/presentation/camera_scan_screen.dart';

import '../../features/home/presentation/home_screen.dart';

import '../../features/welcome/presentation/welcome_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const CameraScanScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const AiChatScreen(),
      ),
    ],
  );
});
