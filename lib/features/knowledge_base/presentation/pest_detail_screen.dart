import 'package:flutter/material.dart';
import '../data/pest_database.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';

class PestDetailScreen extends StatelessWidget {
  final String pestId;

  const PestDetailScreen({super.key, required this.pestId});

  @override
  Widget build(BuildContext context) {
    final pest = PestDatabase.pests.firstWhere((p) => p.id == pestId, orElse: () => PestDatabase.pests.first);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(pest.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      pest.imageAsset,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 250,
                        color: Colors.grey.withValues(alpha: 0.3),
                        child: const Icon(Icons.bug_report, color: Colors.white54, size: 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection('Scientific Name', pest.scientificName, Icons.science),
                  const SizedBox(height: 16),
                  _buildSection('Symptoms', pest.symptoms, Icons.warning_amber_rounded),
                  const SizedBox(height: 16),
                  _buildSection('Prevention & Control', pest.prevention, Icons.shield_outlined),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.greenAccent, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
