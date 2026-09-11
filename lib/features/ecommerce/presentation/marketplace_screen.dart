import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_farm_background.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Direct Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sell Harvest feature coming soon!')));
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: AnimatedFarmBackground(),
          ),
          SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: 4, // Mock data
              itemBuilder: (context, index) {
                final items = [
                  {'name': 'Organic Tomatoes', 'price': '150/kg', 'qty': '50kg', 'seller': 'Nimal'},
                  {'name': 'Fresh Carrots', 'price': '220/kg', 'qty': '100kg', 'seller': 'Sunil'},
                  {'name': 'Green Beans', 'price': '180/kg', 'qty': '30kg', 'seller': 'Kamal'},
                  {'name': 'Big Onions', 'price': '280/kg', 'qty': '200kg', 'seller': 'Ajith'},
                ];
                
                return _ProductCard(
                  name: items[index]['name']!,
                  price: items[index]['price']!,
                  qty: items[index]['qty']!,
                  seller: items[index]['seller']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String qty;
  final String seller;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.qty,
    required this.seller,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.green.shade900.withValues(alpha: 0.5),
                  child: const Center(
                    child: Icon(Icons.eco, size: 48, color: Colors.greenAccent),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Rs. $price',
                        style: TextStyle(color: Colors.greenAccent.shade400, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.scale, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(qty, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(seller, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contacting seller...')));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent.shade400,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Contact', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
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
    );
  }
}
