import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/local_db/app_database.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LedgerRepository(db);
});

class LedgerRepository {
  final AppDatabase _db;

  LedgerRepository(this._db);

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
    await _db.insertLedgerEntry(
      LedgerEntriesCompanion.insert(
        amount: amount,
        type: type,
        category: category,
        date: date,
        description: Value(description),
      ),
    );
  }
  
  Future<void> deleteEntry(LedgerEntry entry) async {
    await _db.deleteLedgerEntry(entry);
  }
}
