import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/market_provider.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../l10n/app_localizations.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all'; // 'all', 'vegetable', 'fruit', 'grain'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                // Search and Filter Bar
                _buildSearchAndFilters(context, l10n),

                // Market List
                Expanded(
                  child: marketPricesAsync.when(
                    data: (prices) {
                      final filtered = prices.where((item) {
                        final rawCrop = (item['crop'] ?? '').toString();
                        final rawMarket = (item['market'] ?? '').toString();
                        final cat = (item['category'] ?? 'vegetable').toString().toLowerCase();
                        final localizedCrop = _getLocalizedCropName(context, rawCrop).toLowerCase();
                        final localizedMarket = _getLocalizedMarket(context, rawMarket).toLowerCase();

                        // Category filter
                        if (_selectedCategory != 'all') {
                          if (_selectedCategory == 'grain') {
                            if (cat != 'grain' && cat != 'spice') return false;
                          } else if (cat != _selectedCategory) {
                            return false;
                          }
                        }

                        // Search query
                        if (_searchQuery.isNotEmpty) {
                          final q = _searchQuery.toLowerCase().trim();
                          final match = rawCrop.toLowerCase().contains(q) ||
                              rawMarket.toLowerCase().contains(q) ||
                              localizedCrop.contains(q) ||
                              localizedMarket.contains(q);
                          if (!match) return false;
                        }

                        return true;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 56, color: Colors.white.withValues(alpha: 0.6)),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.noProduceFound,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index] as Map<String, dynamic>;
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchBg = isDark ? const Color(0xFF131F30).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92);
    final searchBorder = isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Search Field
          Container(
            decoration: BoxDecoration(
              color: searchBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: searchBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchCrops,
                hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18, color: subtextColor),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('all', l10n.allCategories),
                _buildCategoryChip('vegetable', l10n.vegetables),
                _buildCategoryChip('fruit', l10n.fruits),
                _buildCategoryChip('grain', l10n.grainsAndSpices),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String categoryKey, String label) {
    final isSelected = _selectedCategory == categoryKey;
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? const Color(0xFF131F30).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.85);
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategory = categoryKey;
            });
          }
        },
        selectedColor: primary,
        backgroundColor: chipBg,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isSelected ? primary : borderCol),
      ),
    );
  }

  IconData _getCropIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'fruit':
        return Icons.apple;
      case 'grain':
      case 'spice':
        return Icons.grain;
      case 'vegetable':
      default:
        return Icons.eco;
    }
  }

  String _getLocalizedCropName(BuildContext context, String crop) {
    final lang = Localizations.localeOf(context).languageCode;
    final key = crop.toLowerCase().trim();
    if (lang == 'si') {
      switch (key) {
        case 'samba rice': return 'සම්බා සහල්';
        case 'nadu rice': return 'නාඩු සහල්';
        case 'rice':
        case 'paddy': return 'වී / සහල්';
        case 'carrot': return 'කැරට්';
        case 'tomato': return 'තක්කාලි';
        case 'big onion': return 'ලොකු ළූණු';
        case 'red onion': return 'රතු ළූණු';
        case 'potato': return 'අර්තාපල්';
        case 'cabbage': return 'ගෝවා';
        case 'green chilli':
        case 'chilli': return 'අමු මිරිස්';
        case 'beans': return 'බෝංචි';
        case 'brinjal':
        case 'eggplant': return 'වම්බටු';
        case 'pumpkin': return 'වට්ටක්කා';
        case 'beetroot': return 'බීට්රූට්';
        case 'leeks': return 'ලීක්ස්';
        case 'bitter gourd': return 'කරවිල';
        case 'ladies finger':
        case 'okra': return 'බණ්ඩක්කා';
        case 'cucumber': return 'පිපිඤ්ඤා';
        case 'snake gourd': return 'පතෝල';
        case 'banana': return 'කෙසෙල්';
        case 'papaya': return 'පැපොල්';
        case 'lime': return 'දෙහි';
        case 'sweet corn':
        case 'maize':
        case 'corn': return 'බඩඉරිඟු';
        case 'coconut': return 'පොල්';
        case 'ginger': return 'ඉඟුරු';
        case 'black pepper': return 'ගම්මිරිස්';
        case 'mango': return 'අඹ';
        case 'pineapple': return 'අන්නාසි';
        default: return crop;
      }
    } else if (lang == 'ta') {
      switch (key) {
        case 'samba rice': return 'சம்பா அரிசி';
        case 'nadu rice': return 'நாடு அரிசி';
        case 'rice':
        case 'paddy': return 'நெல் / அரிசி';
        case 'carrot': return 'கேரட்';
        case 'tomato': return 'தக்காளி';
        case 'big onion': return 'பெரிய வெங்காயம்';
        case 'red onion': return 'சின்ன வெங்காயம்';
        case 'potato': return 'உருளைக்கிழங்கு';
        case 'cabbage': return 'முட்டைக்கோஸ்';
        case 'green chilli':
        case 'chilli': return 'பச்சை மிளகாய்';
        case 'beans': return 'பீன்ஸ்';
        case 'brinjal':
        case 'eggplant': return 'கத்தரிக்காய்';
        case 'pumpkin': return 'பூசணிக்காய்';
        case 'beetroot': return 'பீட்ரூட்';
        case 'leeks': return 'லீக்ஸ்';
        case 'bitter gourd': return 'பாகற்காய்';
        case 'ladies finger':
        case 'okra': return 'வெண்டைக்காய்';
        case 'cucumber': return 'வெள்ளரிக்காய்';
        case 'snake gourd': return 'புடலங்காய்';
        case 'banana': return 'வாழைப்பழம்';
        case 'papaya': return 'பப்பாளி';
        case 'lime': return 'எலுமிச்சை';
        case 'sweet corn':
        case 'maize':
        case 'corn': return 'சோளம்';
        case 'coconut': return 'தேங்காய்';
        case 'ginger': return 'இஞ்சி';
        case 'black pepper': return 'கருப்பு மிளகு';
        case 'mango': return 'மாம்பழம்';
        case 'pineapple': return 'அன்னாசிப்பழம்';
        default: return crop;
      }
    }
    return crop;
  }

  String _getLocalizedMarket(BuildContext context, String market) {
    final lang = Localizations.localeOf(context).languageCode;
    final key = market.toLowerCase().trim();
    if (lang == 'si') {
      switch (key) {
        case 'dambulla': return 'දඹුල්ල';
        case 'nuwara eliya': return 'නුවරඑළිය';
        case 'pettah': return 'පිටකොටුව';
        case 'keppetipola': return 'කැප්පෙටිපොල';
        case 'kandy': return 'මහනුවර';
        case 'meegoda': return 'මීගොඩ';
        case 'thambuththegama': return 'තඹුත්තේගම';
        case 'kurunegala': return 'කුරුණෑගල';
        default: return market;
      }
    } else if (lang == 'ta') {
      switch (key) {
        case 'dambulla': return 'தம்புள்ளை';
        case 'nuwara eliya': return 'நுவரெலியா';
        case 'pettah': return 'புறக்கோட்டை';
        case 'keppetipola': return 'கெப்பெட்டிபொல';
        case 'kandy': return 'கண்டி';
        case 'meegoda': return 'மீகொட';
        case 'thambuththegama': return 'தம்பத்தேகம';
        case 'kurunegala': return 'குருநாகல்';
        default: return market;
      }
    }
    return market;
  }

  String _getLocalizedUnit(BuildContext context, String unit) {
    final lang = Localizations.localeOf(context).languageCode;
    final key = unit.toLowerCase().trim();
    if (lang == 'si') {
      if (key == 'kg' || key == '1kg') return 'කි.ග්‍රෑ';
      if (key == 'item') return 'ගෙඩිය';
    } else if (lang == 'ta') {
      if (key == 'kg' || key == '1kg') return 'கிலோ';
      if (key == 'item') return 'எண்ணிக்கை';
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
    final category = item['category']?.toString();

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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showMarketDetailBottomSheet(context, item, l10n),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Crop Icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getCropIcon(category), color: Theme.of(context).colorScheme.tertiary, size: 24),
                ),
                const SizedBox(width: 14),

                // Crop Name & Market Location (Spacious, Multi-line capable)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop,
                        style: TextStyle(
                          fontSize: 17, 
                          fontWeight: FontWeight.bold, 
                          color: Theme.of(context).colorScheme.primary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              market,
                              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Price and Trend Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_getCurrencySymbol(context)} $price',
                      style: TextStyle(
                        fontSize: 19, 
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.perUnit(_getLocalizedUnit(context, unit.toString())),
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: trendColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(trendIcon, color: trendColor, size: 12),
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

                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMarketDetailBottomSheet(BuildContext context, Map<String, dynamic> item, AppLocalizations l10n) {
    final rawCrop = item['crop'] ?? 'Unknown';
    final cropLocalized = _getLocalizedCropName(context, rawCrop.toString());
    final rawMarket = item['market'] ?? '';
    final marketLocalized = _getLocalizedMarket(context, rawMarket.toString());
    final price = item['price'] ?? 0;
    final unit = item['unit'] ?? 'kg';
    final localizedUnit = _getLocalizedUnit(context, unit.toString());
    final trend = item['trend'] ?? 'stable';
    final changePercent = item['changePercent'] ?? '';
    final minPrice = item['minPrice'] ?? (price * 0.9).roundToDouble();
    final maxPrice = item['maxPrice'] ?? (price * 1.15).roundToDouble();
    final wholesale = item['wholesalePrice'] ?? (price * 0.92).roundToDouble();
    final retail = item['retailPrice'] ?? (price * 1.18).roundToDouble();
    final otherMarkets = item['otherMarkets'] as List<dynamic>? ?? [];
    final category = item['category']?.toString();

    final lang = Localizations.localeOf(context).languageCode;
    final aiInsightsMap = item['aiInsight'] as Map<String, dynamic>?;
    final aiInsightText = aiInsightsMap != null
        ? (aiInsightsMap[lang] ?? aiInsightsMap['en'] ?? '')
        : '';

    Color trendColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    IconData trendIcon = Icons.remove;
    if (trend == 'up') {
      trendColor = Theme.of(context).colorScheme.error;
      trendIcon = Icons.trending_up;
    } else if (trend == 'down') {
      trendColor = Theme.of(context).colorScheme.secondary;
      trendIcon = Icons.trending_down;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_getCropIcon(category), color: Theme.of(context).colorScheme.primary, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cropLocalized,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$rawCrop • $marketLocalized',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Price Highlight Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
                        Theme.of(context).colorScheme.tertiary.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.priceDetails,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getCurrencySymbol(context)} $price',
                            style: TextStyle(
                              fontSize: 30, 
                              fontWeight: FontWeight.w900, 
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            l10n.perUnit(localizedUnit),
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: trendColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: trendColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(trendIcon, color: trendColor, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  _getLocalizedTrend(context, trend.toString(), l10n),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: trendColor, fontSize: 13),
                                ),
                              ],
                            ),
                            if (changePercent.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                changePercent,
                                style: TextStyle(fontWeight: FontWeight.w900, color: trendColor, fontSize: 13),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Wholesale vs Retail Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131F30) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.wholesalePrice,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_getCurrencySymbol(context)} $wholesale',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131F30) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.retailPrice,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_getCurrencySymbol(context)} $retail',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Min - Max Range Row
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131F30) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.minPrice,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            ),
                          ),
                          Text(
                            '${_getCurrencySymbol(context)} $minPrice',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.compare_arrows_rounded,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.maxPrice,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            ),
                          ),
                          Text(
                            '${_getCurrencySymbol(context)} $maxPrice',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Other Markets Comparison (if available)
                if (otherMarkets.isNotEmpty) ...[
                  Text(
                    l10n.otherMarkets,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131F30) : const Color(0xFFF8FAFC),
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: otherMarkets.map((om) {
                        final mName = _getLocalizedMarket(context, (om['market'] ?? '').toString());
                        final mPrice = om['price'] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.storefront,
                                    size: 16,
                                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(mName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                ],
                              ),
                              Text(
                                '${_getCurrencySymbol(context)} $mPrice',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // AI Market Insight Box (Tri-lingual advice)
                if (aiInsightText.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.amber.withValues(alpha: 0.15) : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.amber.withValues(alpha: 0.3) : Colors.amber.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.smart_toy_rounded,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.amberAccent : Colors.amber.shade900,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.aiMarketInsight,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.amberAccent : Colors.amber.shade900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aiInsightText,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.amber.shade100 : Colors.brown.shade900,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action: Sell in Marketplace Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/ecommerce/add');
                  },
                  icon: const Icon(Icons.add_business_rounded, color: Colors.white),
                  label: Text(
                    l10n.sellThisCrop,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

