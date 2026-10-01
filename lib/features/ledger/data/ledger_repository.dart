import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/services/firebase_sync_service.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncService = ref.watch(firebaseSyncServiceProvider);
  return LedgerRepository(db, syncService);
});

class LedgerRepository {
  final AppDatabase _db;
  final FirebaseSyncService _syncService;

  LedgerRepository(this._db, this._syncService);

  Future<List<LedgerEntry>> getEntries() {
    return _db.getAllLedgerEntries();
  }

  Future<void> addEntry({
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    final id = await _db.insertLedgerEntry(
      LedgerEntriesCompanion.insert(
        amount: amount,
        type: type,
        category: category,
        date: date,
        description: Value(description),
      ),
    );
    _syncService.syncLedgerEntry(
      id: id,
      type: type,
      category: category,
      amount: amount,
      date: date,
      description: description,
    );
  }
  
  Future<void> deleteEntry(LedgerEntry entry) async {
    await _db.deleteLedgerEntry(entry);
    _syncService.deleteLedgerEntry(entry.id);
  }
}
