import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/local_db/app_database.dart';
import 'package:drift/drift.dart';

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FarmRepository(db);
});

class FarmRepository {
  final AppDatabase _db;

  FarmRepository(this._db);

  // Crops
  Future<List<Crop>> getCrops() => _db.getAllCrops();
  
  Future<void> addCrop(Crop crop) async {
    await _db.insertCrop(CropsCompanion.insert(
      id: crop.id,
      name: crop.name,
      variety: Value(crop.variety),
      plantDate: crop.plantDate,
      expectedHarvestDate: Value(crop.expectedHarvestDate),
      area: Value(crop.area),
      areaUnit: Value(crop.areaUnit),
      createdAt: crop.createdAt,
    ));
    // TODO: Sync to backend
  }

  Future<void> deleteCrop(Crop crop) => _db.deleteCrop(crop);

  // Tasks
  Future<List<Task>> getTasks() => _db.getAllTasks();
  
  Future<List<Task>> getTasksForCrop(String cropId) => _db.getTasksForCrop(cropId);

  Future<void> addTask(Task task) async {
    await _db.insertTask(TasksCompanion.insert(
      id: task.id,
      cropId: task.cropId,
      title: task.title,
      description: Value(task.description),
      dueDate: task.dueDate,
      isCompleted: Value(task.isCompleted),
      createdAt: task.createdAt,
    ));
    // TODO: Sync to backend
  }
  
  Future<void> updateTaskStatus(Task task, bool isCompleted) async {
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    await _db.updateTask(updatedTask);
    // TODO: Sync to backend
  }
  
  Future<void> deleteTask(Task task) => _db.deleteTask(task);
}
