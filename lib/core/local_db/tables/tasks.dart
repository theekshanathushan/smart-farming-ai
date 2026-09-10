import 'package:drift/drift.dart';
import 'crops.dart';

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get cropId => text().references(Crops, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
