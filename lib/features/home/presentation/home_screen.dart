import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/weather_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Green
              Color(0xFFF5F5DC), // Cream
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Welcome to\nAgriAI',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Your local agricultural expert',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
              
              // Weather Dashboard Widget
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _WeatherDashboard(),
              ),
              
              const Spacer(),
              
              // Navigation Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        title: 'Camera\nScan',
                        icon: Icons.camera_alt_rounded,
                        color: Colors.green.shade800,
                        onTap: () => context.go('/scan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        title: 'AI\nChat',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: Colors.lightGreen.shade700,
                        onTap: () => context.go('/chat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        title: 'Market\nPrices',
                        icon: Icons.storefront_rounded,
                        color: Colors.orange.shade700,
                        onTap: () => context.go('/market'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: weatherAsync.when(
        data: (weather) {
          final temp = weather['temperature'] ?? '--';
          final desc = weather['description'] ?? 'Current Weather';
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$temp°C',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 32, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.wb_sunny_rounded, // Simple fallback icon
                color: Colors.amber,
                size: 48,
              ),
            ],
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (err, stack) => Column(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white54, size: 32),
            const SizedBox(height: 8),
            Text(
              'Weather unavailable',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
