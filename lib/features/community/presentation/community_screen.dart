import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_farm_background.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Farmer Community', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create Post coming soon!')));
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3, // Mock data
              itemBuilder: (context, index) {
                return _PostCard(
                  author: index == 0 ? 'Kamal Perera' : 'Sunil Shantha',
                  time: '${index + 1} hours ago',
                  content: index == 0 
                    ? 'My tomato plants have these black spots on the leaves. Does anyone know what disease this is and what fertilizer I should use?'
                    : 'Great harvest of beans today! The weather has been really good for the crops this season.',
                  likes: 12 - index * 3,
                  comments: 4 - index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String author;
  final String time;
  final String content;
  final int likes;
  final int comments;

  const _PostCard({
    required this.author,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green.shade400,
                      child: Text(author[0], style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(time, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, color: Colors.greenAccent.shade200, size: 20),
                    const SizedBox(width: 4),
                    Text('$likes', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 24),
                    Icon(Icons.comment_outlined, color: Colors.blueAccent.shade200, size: 20),
                    const SizedBox(width: 4),
                    Text('$comments', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
