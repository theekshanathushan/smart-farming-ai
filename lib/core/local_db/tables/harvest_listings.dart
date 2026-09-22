import 'package:drift/drift.dart';

class HarvestListings extends Table {
  TextColumn get id => text()();
  TextColumn get cropName => text()();
  TextColumn get category => text()(); // Vegetable, Fruit, Grain, Spices, Other
  RealColumn get quantity => real()();
  TextColumn get unit => text().withDefault(const Constant('kg'))(); // kg, bags, tons, bunches
  RealColumn get pricePerUnit => real()(); // Price in LKR
  TextColumn get grade => text().withDefault(const Constant('Grade A'))(); // Grade A, Grade B, Organic
  DateTimeColumn get harvestDate => dateTime()();
  TextColumn get district => text()(); // e.g. Dambulla, Nuwara Eliya, Jaffna, Kandy
  TextColumn get farmerName => text()();
  TextColumn get farmerPhone => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isSold => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
