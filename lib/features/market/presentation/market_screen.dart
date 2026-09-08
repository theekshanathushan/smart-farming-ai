import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/market_provider.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketPricesAsync = ref.watch(marketPricesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[100],
        child: marketPricesAsync.when(
          data: (prices) {
            if (prices.isEmpty) {
              return const Center(child: Text('No price data available'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: prices.length,
              itemBuilder: (context, index) {
                final item = prices[index];
                return _buildPriceCard(item);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${error.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(marketPricesProvider),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
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
      trendColor = Colors.red;
      trendIcon = Icons.arrow_upward;
    } else if (trend == 'down') {
      trendColor = Colors.green;
      trendIcon = Icons.arrow_downward;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  market,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. $price',
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                      ),
                    ),
                    Text(
                      'per $unit',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(trendIcon, color: trendColor, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
