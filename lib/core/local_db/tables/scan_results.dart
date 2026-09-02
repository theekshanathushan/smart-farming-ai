import 'package:drift/drift.dart';

class ScanResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imagePath => text()();
  TextColumn get predictedLabel => text()();
  RealColumn get confidence => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get notes => text().nullable()();
}
