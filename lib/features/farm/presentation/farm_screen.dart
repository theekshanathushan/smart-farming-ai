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
      appBar: AppBar(
        title: const Text('My Farm'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Crops', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/farm/add-crop'),
                  child: const Text('+ Add Crop'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            cropsAsync.when(
              data: (crops) => crops.isEmpty 
                  ? const Card(child: Padding(padding: EdgeInsets.all(16), child: Text("No crops added yet.")))
                  : SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: crops.length,
                        itemBuilder: (context, index) {
                          final crop = crops[index];
                          return Card(
                            margin: const EdgeInsets.only(right: 12),
                            child: Container(
                              width: 140,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (crop.variety != null) Text(crop.variety!),
                                  const Spacer(),
                                  Text('${crop.area ?? 0} ${crop.areaUnit ?? "acres"}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            const Text('Daily Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            tasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const Card(child: Padding(padding: EdgeInsets.all(16), child: Text("No tasks for today!")))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return CheckboxListTile(
                          title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                          subtitle: task.description != null ? Text(task.description!) : null,
                          value: task.isCompleted,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(farmRepositoryProvider).updateTaskStatus(task, val);
                              ref.invalidate(tasksProvider);
                            }
                          },
                        );
                      },
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
