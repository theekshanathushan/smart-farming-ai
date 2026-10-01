import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tables/scan_results.dart';
import 'tables/crops.dart';
import 'tables/tasks.dart';
import 'tables/ledger_entries.dart';
import 'tables/harvest_listings.dart';
import 'tables/chat_messages.dart';

part 'app_database.g.dart';

// Provide the database globally
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

@DriftDatabase(tables: [ScanResults, Crops, Tasks, LedgerEntries, HarvestListings, ChatMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(scanResults);
          }
          if (from < 3) {
            await m.createTable(crops);
            await m.createTable(tasks);
          }
          if (from < 4) {
            await m.createTable(ledgerEntries);
          }
          if (from < 5) {
            await m.createTable(harvestListings);
          }
          if (from < 6) {
            await m.createTable(chatMessages);
          }
        },
      );

  // DAOs for ScanResults
  Future<int> insertScanResult(ScanResultsCompanion result) {
    return into(scanResults).insert(result);
  }

  Future<List<ScanResult>> getAllScanResults() {
    return (select(scanResults)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).get();
  }

  // DAOs for Crops
  Future<int> insertCrop(CropsCompanion crop) => into(crops).insert(crop);
  Future<List<Crop>> getAllCrops() => select(crops).get();
  Future<bool> updateCrop(Crop crop) => update(crops).replace(crop);
  Future<int> deleteCrop(Crop crop) => delete(crops).delete(crop);

  // DAOs for Tasks
  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);
  Future<List<Task>> getAllTasks() => select(tasks).get();
  Future<List<Task>> getTasksForCrop(String cropId) => (select(tasks)..where((t) => t.cropId.equals(cropId))).get();
  Future<bool> updateTask(Task task) => update(tasks).replace(task);
  Future<int> deleteTask(Task task) => delete(tasks).delete(task);

  // DAOs for LedgerEntries
  Future<int> insertLedgerEntry(LedgerEntriesCompanion entry) => into(ledgerEntries).insert(entry);
  Future<List<LedgerEntry>> getAllLedgerEntries() => (select(ledgerEntries)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  Future<int> deleteLedgerEntry(LedgerEntry entry) => delete(ledgerEntries).delete(entry);

  // DAOs for HarvestListings
  Future<int> insertHarvestListing(HarvestListingsCompanion listing) => into(harvestListings).insert(listing);
  Future<List<HarvestListing>> getAllHarvestListings() =>
      (select(harvestListings)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  Future<List<HarvestListing>> getActiveHarvestListings() =>
      (select(harvestListings)
        ..where((t) => t.isSold.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();
  Future<List<HarvestListing>> getHarvestListingsByPhone(String phone) =>
      (select(harvestListings)
        ..where((t) => t.farmerPhone.equals(phone))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();
  Future<HarvestListing?> getHarvestListingById(String id) =>
      (select(harvestListings)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<bool> updateHarvestListing(HarvestListing listing) => update(harvestListings).replace(listing);
  Future<int> markHarvestAsSold(String id) =>
      (update(harvestListings)..where((t) => t.id.equals(id))).write(const HarvestListingsCompanion(isSold: Value(true)));
  Future<int> deleteHarvestListing(String id) =>
      (delete(harvestListings)..where((t) => t.id.equals(id))).go();

  // DAOs for ChatMessages
  Future<int> insertChatMessage(ChatMessagesCompanion message) => into(chatMessages).insert(message);
  Future<List<ChatMessageEntry>> getAllChatMessages() =>
      (select(chatMessages)..orderBy([(t) => OrderingTerm.asc(t.timestamp)])).get();
  Stream<List<ChatMessageEntry>> watchAllChatMessages() =>
      (select(chatMessages)..orderBy([(t) => OrderingTerm.asc(t.timestamp)])).watch();
  Future<int> clearChatHistory() => delete(chatMessages).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
