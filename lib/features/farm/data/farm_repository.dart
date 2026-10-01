import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/services/firebase_sync_service.dart';
import 'package:drift/drift.dart';

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncService = ref.watch(firebaseSyncServiceProvider);
  return FarmRepository(db, syncService);
});

class FarmRepository {
  final AppDatabase _db;
  final FirebaseSyncService _syncService;

  FarmRepository(this._db, this._syncService);

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
    _syncService.syncCrop(
      id: crop.id,
      name: crop.name,
      variety: crop.variety,
      plantDate: crop.plantDate,
      expectedHarvestDate: crop.expectedHarvestDate,
      area: crop.area,
      areaUnit: crop.areaUnit,
    );
  }

  Future<void> deleteCrop(Crop crop) async {
    await _db.deleteCrop(crop);
    _syncService.deleteCrop(crop.id);
  }

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
    _syncService.syncTask(
      id: task.id,
      cropId: task.cropId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
    );
  }
  
  Future<void> updateTaskStatus(Task task, bool isCompleted) async {
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    await _db.updateTask(updatedTask);
    _syncService.syncTask(
      id: updatedTask.id,
      cropId: updatedTask.cropId,
      title: updatedTask.title,
      description: updatedTask.description,
      dueDate: updatedTask.dueDate,
      isCompleted: updatedTask.isCompleted,
      createdAt: updatedTask.createdAt,
    );
  }
  
  Future<void> deleteTask(Task task) async {
    await _db.deleteTask(task);
    _syncService.deleteTask(task.id);
  }
}
