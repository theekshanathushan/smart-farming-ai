import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/farm_repository.dart';
import '../../../core/local_db/app_database.dart';
import 'package:go_router/go_router.dart';

final tasksProvider = FutureProvider<List<Task>>((ref) {
  return ref.watch(farmRepositoryProvider).getTasks();
});

final cropsProvider = FutureProvider<List<Crop>>((ref) {
  return ref.watch(farmRepositoryProvider).getCrops();
});

class FarmScreen extends ConsumerWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(cropsProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Farm', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Crops', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      TextButton.icon(
                        onPressed: () => context.push('/farm/add-crop'),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Crop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  cropsAsync.when(
                    data: (crops) => crops.isEmpty 
                        ? const _GlassCard(child: Padding(padding: EdgeInsets.all(16), child: Text("No crops added yet.", style: TextStyle(color: Colors.white))))
                        : SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: crops.length,
                              itemBuilder: (context, index) {
                                final crop = crops[index];
                                return Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: _GlassCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent.shade400.withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.eco, color: Colors.greenAccent, size: 24),
                                          ),
                                          const Spacer(),
                                          Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                          if (crop.variety != null) Text(crop.variety!, style: const TextStyle(color: Colors.white70)),
                                          Text('${crop.area ?? 0} ${crop.areaUnit ?? "acres"}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    loading: () => const CircularProgressIndicator(color: Colors.white),
                    error: (e, st) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 24),
                  const Text('Quick Actions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ActionBtn(icon: Icons.water_drop, label: 'Water All', color: Colors.blueAccent),
                        _ActionBtn(icon: Icons.eco, label: 'Fertilize', color: Colors.greenAccent),
                        _ActionBtn(icon: Icons.agriculture, label: 'Harvest', color: Colors.orangeAccent),
                        _ActionBtn(icon: Icons.note_add, label: 'Add Note', color: Colors.purpleAccent),
                        _ActionBtn(
                          icon: Icons.smart_toy, 
                          label: 'AI Advice', 
                          color: Colors.tealAccent,
                          onTap: () => context.push('/chat'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Daily Tasks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  tasksAsync.when(
                    data: (tasks) => tasks.isEmpty
                        ? const _GlassCard(child: Padding(padding: EdgeInsets.all(16), child: Text("No tasks for today!", style: TextStyle(color: Colors.white))))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _GlassCard(
                                  child: CheckboxListTile(
                                    title: Text(task.title, style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                      decorationColor: Colors.white70,
                                    )),
                                    subtitle: task.description != null ? Text(task.description!, style: const TextStyle(color: Colors.white70)) : null,
                                    value: task.isCompleted,
                                    activeColor: Colors.greenAccent.shade400,
                                    checkColor: Colors.black,
                                    side: const BorderSide(color: Colors.white54, width: 2),
                                    onChanged: (val) {
                                      if (val != null) {
                                        ref.read(farmRepositoryProvider).updateTaskStatus(task, val);
                                        ref.invalidate(tasksProvider);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                    loading: () => const CircularProgressIndicator(color: Colors.white),
                    error: (e, st) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label action triggered'), backgroundColor: Colors.black87));
        },
        borderRadius: BorderRadius.circular(24),
        child: _GlassCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
