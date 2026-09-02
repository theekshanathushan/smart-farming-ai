import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/ai_agent/presentation/chat_screen.dart';

// Placeholder screens for routing
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AgriAI - Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/scan'),
              child: const Text('Camera Scan'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/chat'),
              child: const Text('AI Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraScanScreen extends StatelessWidget {
  const CameraScanScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: const Center(child: Text('Camera Scan Screen')),
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
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
