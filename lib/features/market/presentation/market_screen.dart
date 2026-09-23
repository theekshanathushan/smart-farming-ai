import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/market_provider.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../l10n/app_localizations.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketPricesAsync = ref.watch(marketPricesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.marketPricesTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedFarmBackground(),
          ),
          
          SafeArea(
            child: marketPricesAsync.when(
              data: (prices) {
                if (prices.isEmpty) {
                  return Center(
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'si'
                          ? 'මිල දත්ත නොමැත'
                          : (Localizations.localeOf(context).languageCode == 'ta' ? 'விலை விபரம் கிடைக்கவில்லை' : 'No price data available'),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    final item = prices[index];
                    return _buildPriceCard(context, item, l10n);
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
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.tertiary),
                      child: Text(l10n.tryAgain, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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

  String _getLocalizedCropName(BuildContext context, String crop) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'si') {
      switch (crop.toLowerCase().trim()) {
        case 'samba rice': return 'සම්බා සහල්';
        case 'rice':
        case 'paddy': return 'වී / සහල්';
        case 'carrot': return 'කැරට්';
        case 'tomato': return 'තක්කාලි';
        case 'big onion': return 'ලොකු ළූණු';
        case 'red onion': return 'රතු ළූණු';
        case 'potato': return 'අර්තාපල්';
        case 'cabbage': return 'ගෝවා';
        case 'chilli':
        case 'green chilli': return 'අමු මිරිස්';
        case 'beans': return 'බෝංචි';
        case 'brinjal':
        case 'eggplant': return 'වම්බටු';
        case 'pumpkin': return 'වට්ටක්කා';
        case 'maize':
        case 'corn': return 'ඉරිඟු';
        case 'banana': return 'කෙසෙල්';
        default: return crop;
      }
    } else if (lang == 'ta') {
      switch (crop.toLowerCase().trim()) {
        case 'samba rice': return 'சம்பா அரிசி';
        case 'rice':
        case 'paddy': return 'நெல் / அரிசி';
        case 'carrot': return 'கேரட்';
        case 'tomato': return 'தக்காளி';
        case 'big onion': return 'பெரிய வெங்காயம்';
        case 'red onion': return 'சின்ன வெங்காயம்';
        case 'potato': return 'உருளைக்கிழங்கு';
        case 'cabbage': return 'முட்டைக்கோஸ்';
        case 'chilli':
        case 'green chilli': return 'பச்சை மிளகாய்';
        case 'beans': return 'பீன்ஸ்';
        case 'brinjal':
        case 'eggplant': return 'கத்தரிக்காய்';
        case 'pumpkin': return 'பூசணிக்காய்';
        case 'maize':
        case 'corn': return 'சோளம்';
        case 'banana': return 'வாழைப்பழம்';
        default: return crop;
      }
    }
    return crop;
  }

  String _getLocalizedMarket(BuildContext context, String market) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'si') {
      switch (market.toLowerCase().trim()) {
        case 'dambulla': return 'දඹුල්ල';
        case 'nuwara eliya': return 'නුවරඑළිය';
        case 'pettah': return 'පිටකොටුව';
        case 'keppetipola': return 'කැප්පෙටිපොල';
        case 'kandy': return 'මහනුවර';
        case 'meegoda': return 'මීගොඩ';
        case 'thambuththegama': return 'තඹුත්තේගම';
        default: return market;
      }
    } else if (lang == 'ta') {
      switch (market.toLowerCase().trim()) {
        case 'dambulla': return 'தம்புள்ளை';
        case 'nuwara eliya': return 'நுவரெலியா';
        case 'pettah': return 'புறக்கோட்டை';
        case 'keppetipola': return 'கெப்பெட்டிபொல';
        case 'kandy': return 'கண்டி';
        case 'meegoda': return 'மீகொட';
        case 'thambuththegama': return 'தம்பத்தேகம';
        default: return market;
      }
    }
    return market;
  }

  String _getLocalizedUnit(BuildContext context, String unit) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'si') {
      if (unit.toLowerCase() == 'kg') return 'කි.ග්‍රෑ';
    } else if (lang == 'ta') {
      if (unit.toLowerCase() == 'kg') return 'கிலோ';
    }
    return unit;
  }

  String _getLocalizedTrend(BuildContext context, String trend, AppLocalizations l10n) {
    switch (trend.toLowerCase()) {
      case 'up':
        return l10n.trendUp;
      case 'down':
        return l10n.trendDown;
      case 'stable':
      default:
        return l10n.trendStable;
    }
  }

  String _getCurrencySymbol(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'si') return 'රු.';
    if (lang == 'ta') return 'ரூ.';
    return 'Rs.';
  }

  Widget _buildPriceCard(BuildContext context, Map<String, dynamic> item, AppLocalizations l10n) {
    final rawCrop = item['crop'] ?? 'Unknown';
    final crop = _getLocalizedCropName(context, rawCrop.toString());
    final price = item['price'] ?? 0;
    final unit = item['unit'] ?? 'kg';
    final trend = item['trend'] ?? 'stable';
    final rawMarket = item['market'] ?? '';
    final market = _getLocalizedMarket(context, rawMarket.toString());

    Color trendColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    IconData trendIcon = Icons.remove;
    
    if (trend == 'up') {
      trendColor = Theme.of(context).colorScheme.error;
      trendIcon = Icons.trending_up;
    } else if (trend == 'down') {
      trendColor = Theme.of(context).colorScheme.secondary;
      trendIcon = Icons.trending_down;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
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
                    backgroundColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                    radius: 28,
                    child: Icon(Icons.eco, color: Theme.of(context).colorScheme.tertiary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                market,
                                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
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
                  '${_getCurrencySymbol(context)} $price',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      l10n.perUnit(_getLocalizedUnit(context, unit.toString())),
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: trendColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(trendIcon, color: trendColor, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            _getLocalizedTrend(context, trend.toString(), l10n),
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
