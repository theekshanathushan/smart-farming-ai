import 'package:drift/drift.dart';

class Crops extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get variety => text().nullable()();
  DateTimeColumn get plantDate => dateTime()();
  DateTimeColumn get expectedHarvestDate => dateTime().nullable()();
  RealColumn get area => real().nullable()();
  TextColumn get areaUnit => text().withDefault(const Constant('acres')).nullable()();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
