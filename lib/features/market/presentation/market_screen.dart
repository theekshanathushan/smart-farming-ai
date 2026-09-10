import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/market_provider.dart';
import '../../../core/theme/app_theme.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketPricesAsync = ref.watch(marketPricesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Market Prices', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Dynamic Background Image - faded at the bottom like Home Screen
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
                    Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.4, 0.5],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: marketPricesAsync.when(
              data: (prices) {
                if (prices.isEmpty) {
                  return const Center(
                    child: Text('No price data available', style: TextStyle(color: Colors.white, fontSize: 18))
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    final item = prices[index];
                    return _buildPriceCard(item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: ${error.toString()}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(marketPricesProvider),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.harvestGold),
                      child: const Text('Retry', style: TextStyle(color: AppTheme.richLoam)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Map<String, dynamic> item) {
    final crop = item['crop'] ?? 'Unknown';
    final price = item['price'] ?? 0;
    final unit = item['unit'] ?? 'kg';
    final trend = item['trend'] ?? 'stable';
    final market = item['market'] ?? '';

    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.remove;
    
    if (trend == 'up') {
      trendColor = Colors.redAccent;
      trendIcon = Icons.trending_up;
    } else if (trend == 'down') {
      trendColor = AppTheme.sprout;
      trendIcon = Icons.trending_down;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.harvestGold.withOpacity(0.2),
                    radius: 28,
                    child: const Icon(Icons.eco, color: AppTheme.harvestGold, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepCanopy),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                market,
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. $price',
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: AppTheme.richLoam
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'per $unit',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: trendColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(trendIcon, color: trendColor, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            trend.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: trendColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
