import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_ai/l10n/app_localizations.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../providers/marketplace_controller.dart';
import 'harvest_detail_screen.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(marketplaceProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final switchBg = isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.85);
    final searchBg = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.85);
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1);

    final categories = [
      {'key': 'All', 'label': l10n.allCategories},
      {'key': 'Vegetables', 'label': l10n.vegetables},
      {'key': 'Fruits', 'label': l10n.fruits},
      {'key': 'Grains', 'label': l10n.grains},
      {'key': 'Spices', 'label': l10n.spices},
      {'key': 'Others', 'label': l10n.others},
    ];

    final displayedListings = state.currentTab == MarketplaceTab.browse
        ? state.filteredBrowseListings
        : state.filteredMyListings;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.harvestMarketplace,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: () => ref.read(marketplaceProvider.notifier).loadListings(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ecommerce/add'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(
          l10n.sellHarvest,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: AnimatedFarmBackground(),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Segmented Switch: Browse Produce vs My Listings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: switchBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => ref.read(marketplaceProvider.notifier).setTab(MarketplaceTab.browse),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: state.currentTab == MarketplaceTab.browse
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                l10n.browseProduce,
                                style: TextStyle(
                                  color: state.currentTab == MarketplaceTab.browse
                                      ? Colors.white
                                      : subtextColor,
                                  fontWeight: state.currentTab == MarketplaceTab.browse
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => ref.read(marketplaceProvider.notifier).setTab(MarketplaceTab.myListings),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: state.currentTab == MarketplaceTab.myListings
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                l10n.myListings,
                                style: TextStyle(
                                  color: state.currentTab == MarketplaceTab.myListings
                                      ? Colors.white
                                      : subtextColor,
                                  fontWeight: state.currentTab == MarketplaceTab.myListings
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: searchBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderCol),
                        ),
                        child: TextField(
                          onChanged: (val) => ref.read(marketplaceProvider.notifier).setSearchQuery(val),
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: l10n.searchProduceHint,
                            hintStyle: TextStyle(color: subtextColor.withValues(alpha: 0.8), fontSize: 13),
                            prefixIcon: Icon(Icons.search, color: subtextColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Category Filter Chips
                if (state.currentTab == MarketplaceTab.browse)
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = state.selectedCategory.toLowerCase() == cat['key']!.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              cat['label']!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: theme.colorScheme.primary,
                            backgroundColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.85),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide(
                              color: isSelected ? theme.colorScheme.primary : borderCol,
                            ),
                            onSelected: (_) => ref.read(marketplaceProvider.notifier).setCategory(cat['key']!),
                          ),
                        );
                      },
                    ),
                  ),

                // Main Listings Grid
                Expanded(
                  child: state.isLoading
                      ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                      : displayedListings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 64, color: subtextColor.withValues(alpha: 0.6)),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.noProduceFound,
                                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  if (state.currentTab == MarketplaceTab.myListings)
                                    ElevatedButton.icon(
                                      onPressed: () => context.push('/ecommerce/add'),
                                      icon: const Icon(Icons.add),
                                      label: Text(l10n.sellHarvest),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.66,
                              ),
                              itemCount: displayedListings.length,
                              itemBuilder: (context, index) {
                                final listing = displayedListings[index];
                                return _HarvestProduceCard(
                                  listing: listing,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HarvestDetailScreen(listing: listing),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HarvestProduceCard extends StatelessWidget {
  final HarvestListing listing;
  final VoidCallback onTap;

  const _HarvestProduceCard({
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.92);
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Icon / Image banner
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                Colors.green.shade900.withValues(alpha: 0.8),
                                Colors.teal.shade900.withValues(alpha: 0.6),
                              ]
                            : [
                                Colors.green.shade100,
                                Colors.teal.shade50,
                              ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            listing.category == 'Fruits'
                                ? Icons.apple
                                : listing.category == 'Grains'
                                    ? Icons.grain
                                    : Icons.eco,
                            size: 42,
                            color: isDark ? Colors.greenAccent : Colors.green.shade800,
                          ),
                        ),
                        // Grade Badge
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              listing.grade,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (listing.isSold)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.soldOut,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Card details
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.cropName,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.pricePerKg(listing.pricePerUnit.toStringAsFixed(0), listing.unit),
                              style: TextStyle(
                                color: isDark ? Colors.greenAccent.shade400 : Colors.green.shade800,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.scale, size: 12, color: subtextColor),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${listing.quantity.toStringAsFixed(0)} ${listing.unit}',
                                    style: TextStyle(color: subtextColor, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    listing.district,
                                    style: TextStyle(color: subtextColor, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Quick Action button
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              l10n.contactFarmer,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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
}
