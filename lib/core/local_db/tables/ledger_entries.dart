import 'package:drift/drift.dart';

@DataClassName('LedgerEntry')
class LedgerEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'income' or 'expense'
  TextColumn get category => text()(); // e.g., 'Seeds', 'Fertilizer', 'Harvest Sale'
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
}
