import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/weather_provider.dart';
import 'package:agri_ai/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background Image - kept to maintain farm context but faded at the bottom
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.asset(
              'assets/images/farm_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient overlay for seamless transition
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.4, 0.5],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InkWell(
                      onTap: () => context.push('/profile'),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.goodMorning,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                authState.name?.isNotEmpty == true ? authState.name! : l10n.farmer,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              backgroundImage: authState.profileImagePath != null
                                  ? FileImage(File(authState.profileImagePath!))
                                  : null,
                              child: authState.profileImagePath == null
                                  ? const Icon(Icons.person, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Weather Dashboard Widget (Refined Glassmorphism)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _WeatherDashboard(),
                  ),

                  // Quick Tools Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.quickTools,
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _QuickToolItem(
                          icon: Icons.add_circle_outline_rounded,
                          label: l10n.addCrop,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/farm/add-crop'),
                        ),
                        _QuickToolItem(
                          icon: Icons.science_outlined,
                          label: l10n.fertilizer,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/fertilizer'),
                        ),
                        _QuickToolItem(
                          icon: Icons.menu_book_rounded,
                          label: l10n.pestGuide,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/guide'),
                        ),
                        _QuickToolItem(
                          icon: Icons.smart_toy_outlined,
                          label: l10n.aiHelper,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/chat'),
                        ),
                        _QuickToolItem(
                          icon: Icons.water_drop_outlined,
                          label: l10n.irrigation,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/irrigation'),
                        ),
                        _QuickToolItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: l10n.ledger,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/ledger'),
                        ),
                        _QuickToolItem(
                          icon: Icons.forum_outlined,
                          label: l10n.community,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/community'),
                        ),
                        _QuickToolItem(
                          icon: Icons.storefront_outlined,
                          label: l10n.buySell,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/ecommerce'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Live Updates / News Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.liveAlerts,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All alerts shown'), backgroundColor: Colors.black87));
                          },
                          child: Text(l10n.seeAll),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Live Updates Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _LiveAlertCard(
                          title: l10n.marketSpikeAlert,
                          description: l10n.marketSpikeDesc,
                          icon: Icons.trending_up_rounded,
                          iconColor: Colors.green.shade600,
                          time: l10n.oneHourAgo,
                        ),
                        const SizedBox(height: 12),
                        _LiveAlertCard(
                          title: l10n.weatherWarningAlert,
                          description: l10n.weatherWarningDesc,
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.orange.shade600,
                          time: l10n.threeHoursAgo,
                        ),
                        const SizedBox(height: 12),
                        _LiveAlertCard(
                          title: l10n.cropScheduleAlert,
                          description: l10n.cropScheduleDesc,
                          icon: Icons.calendar_today_rounded,
                          iconColor: theme.colorScheme.primary,
                          time: l10n.justNow,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120), // Bottom padding for navigation bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: weatherAsync.when(
            data: (weather) {
              final temp = weather['temperature'] ?? '--';
              final desc = weather['description'] ?? l10n.currentWeather;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        desc,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$temp°C',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 42, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Lottie.asset('assets/animations/weather_sun.json'),
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
                const Icon(Icons.cloud_off, color: Colors.white70, size: 32),
                const SizedBox(height: 8),
                Text(
                  l10n.weatherUnavailable,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickToolItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickToolItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 85,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveAlertCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String time;

  const _LiveAlertCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

