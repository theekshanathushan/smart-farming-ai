import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_ai/l10n/app_localizations.dart';
class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: theme.colorScheme.surface,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.2),
            labelTextStyle: WidgetStateProperty.all(
              theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.grass_outlined),
                selectedIcon: const Icon(Icons.grass_rounded),
                label: l10n.navFarm,
              ),
              NavigationDestination(
                icon: const Icon(Icons.camera_alt_outlined),
                selectedIcon: const Icon(Icons.camera_alt_rounded),
                label: l10n.navScan,
              ),
              NavigationDestination(
                icon: const Icon(Icons.storefront_outlined),
                selectedIcon: const Icon(Icons.storefront_rounded),
                label: l10n.navMarket,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
    );
  }
}
