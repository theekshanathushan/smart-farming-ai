import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/farm_repository.dart';
import '../../../core/local_db/app_database.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/animated_farm_background.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('My Farm', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: AnimatedFarmBackground(),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDashboardHeader(context, cropsAsync, tasksAsync, textColor, mutedTextColor),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(context, 'My Crops', textColor, actionLabel: '+ Add Crop', onAction: () => context.push('/farm/add-crop')),
                  const SizedBox(height: 16),
                  _buildCropsSection(context, cropsAsync, textColor, mutedTextColor),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Quick Actions', textColor),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, ref, cropsAsync, textColor),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Daily Tasks', textColor),
                  const SizedBox(height: 16),
                  _buildTasksSection(context, ref, tasksAsync, textColor, mutedTextColor),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color textColor, {String? actionLabel, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textColor)),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildDashboardHeader(BuildContext context, AsyncValue<List<Crop>> cropsAsync, AsyncValue<List<Task>> tasksAsync, Color textColor, Color mutedTextColor) {
    int activeCropsCount = cropsAsync.asData?.value.length ?? 0;
    int pendingTasksCount = tasksAsync.asData?.value.where((t) => !t.isCompleted).length ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Active Crops',
            value: activeCropsCount.toString(),
            icon: Icons.eco,
            iconColor: Theme.of(context).colorScheme.primary,
            textColor: textColor,
            mutedTextColor: mutedTextColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Pending Tasks',
            value: pendingTasksCount.toString(),
            icon: Icons.assignment_late,
            iconColor: Theme.of(context).colorScheme.secondary,
            textColor: textColor,
            mutedTextColor: mutedTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCropsSection(BuildContext context, AsyncValue<List<Crop>> cropsAsync, Color textColor, Color mutedTextColor) {
    final theme = Theme.of(context);
    return cropsAsync.when(
      data: (crops) => crops.isEmpty 
          ? _GlassCard(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.nature_people, size: 48, color: mutedTextColor),
                    const SizedBox(height: 12),
                    Text("No crops added yet.", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )
          : SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    child: _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.eco, color: theme.colorScheme.primary, size: 28),
                            ),
                            const Spacer(),
                            Text(
                              crop.name, 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${crop.area ?? 0} ${crop.areaUnit ?? "acres"}', 
                              style: TextStyle(color: mutedTextColor, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      error: (e, st) => Text('Error: $e', style: TextStyle(color: theme.colorScheme.error)),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, AsyncValue<List<Crop>> cropsAsync, Color textColor) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionBtn(
            icon: Icons.water_drop, 
            label: 'Irrigation', 
            textColor: textColor,
            onTap: () => context.push('/irrigation'),
          ),
          _ActionBtn(
            icon: Icons.science, 
            label: 'Fertilizer',
            textColor: textColor, 
            onTap: () => context.push('/fertilizer'),
          ),
          _ActionBtn(
            icon: Icons.point_of_sale, 
            label: 'Income',
            textColor: textColor, 
            onTap: () => context.push('/ledger/add'),
          ),
          _ActionBtn(
            icon: Icons.note_add, 
            label: 'Add Task',
            textColor: textColor, 
            onTap: () {
              cropsAsync.whenData((crops) {
                if (crops.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please add a crop first to add a task.', style: TextStyle(color: Colors.white)), 
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                  return;
                }
                _showAddNoteDialog(context, ref, crops);
              });
            },
          ),
          _ActionBtn(
            icon: Icons.smart_toy, 
            label: 'AI Advice',
            textColor: textColor, 
            onTap: () => context.push('/chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, WidgetRef ref, AsyncValue<List<Task>> tasksAsync, Color textColor, Color mutedTextColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return tasksAsync.when(
      data: (tasks) => tasks.isEmpty
          ? _GlassCard(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.task_alt, size: 48, color: mutedTextColor),
                    const SizedBox(height: 12),
                    Text("All caught up for today!", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _GlassCard(
                    child: InkWell(
                      onTap: () {
                        ref.read(farmRepositoryProvider).updateTaskStatus(task, !task.isCompleted);
                        ref.invalidate(tasksProvider);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: task.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                                border: Border.all(
                                  color: task.isCompleted 
                                      ? theme.colorScheme.primary 
                                      : (isDark ? Colors.white54 : Colors.black38),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: task.isCompleted ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title, 
                                    style: TextStyle(
                                      color: task.isCompleted ? mutedTextColor.withValues(alpha: 0.5) : textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (task.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description!, 
                                      style: TextStyle(
                                        color: task.isCompleted ? mutedTextColor.withValues(alpha: 0.3) : mutedTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      error: (e, st) => Text('Error: $e', style: TextStyle(color: theme.colorScheme.error)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color mutedTextColor;

  const _StatCard({
    required this.title, 
    required this.value, 
    required this.icon, 
    required this.iconColor,
    required this.textColor,
    required this.mutedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: TextStyle(color: mutedTextColor, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // In light mode, use a slightly transparent white for high contrast with dark text.
    // In dark mode, use a transparent black.
    final cardColor = isDark 
        ? Colors.black.withValues(alpha: 0.4) 
        : Colors.white.withValues(alpha: 0.75);
        
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: 0.1) 
        : Colors.white.withValues(alpha: 0.9);
        
    final shadowColor = isDark 
        ? Colors.black.withValues(alpha: 0.2) 
        : Colors.black.withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
  final Color textColor;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.label, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: _GlassCard(
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? theme.colorScheme.surface.withValues(alpha: 0.3)
                        : theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isDark ? Colors.white : theme.colorScheme.primary, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  label, 
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13), 
                  textAlign: TextAlign.center
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showAddNoteDialog(BuildContext context, WidgetRef ref, List<Crop> crops) {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String selectedCropId = crops.first.id;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Add Farm Task', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCropId,
                    decoration: InputDecoration(
                      labelText: 'Select Crop',
                      filled: true,
                      fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: crops.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCropId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      filled: true,
                      fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      filled: true,
                      fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    cropId: selectedCropId,
                    title: titleController.text.trim(),
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                    dueDate: DateTime.now(), // default to today
                    isCompleted: false,
                    createdAt: DateTime.now(),
                  );
                  ref.read(farmRepositoryProvider).addTask(newTask);
                  ref.invalidate(tasksProvider);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Task added successfully!'), backgroundColor: theme.colorScheme.primary));
                },
                child: const Text('Save Task', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      );
    },
  );
}
