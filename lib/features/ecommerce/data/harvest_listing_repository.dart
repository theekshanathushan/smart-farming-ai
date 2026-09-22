import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/local_db/app_database.dart';

final harvestListingRepositoryProvider = Provider<HarvestListingRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HarvestListingRepository(db);
});

class HarvestListingRepository {
  final AppDatabase _db;
  bool _seeded = false;

  HarvestListingRepository(this._db);

  /// Get active harvest listings (available for buyers to purchase)
  Future<List<HarvestListing>> getActiveListings() async {
    await _checkAndSeedInitialData();
    return _db.getActiveHarvestListings();
  }

  /// Get all harvest listings
  Future<List<HarvestListing>> getAllListings() async {
    await _checkAndSeedInitialData();
    return _db.getAllHarvestListings();
  }

  /// Get listings created by a specific farmer phone number
  Future<List<HarvestListing>> getMyListings(String phone) async {
    await _checkAndSeedInitialData();
    return _db.getHarvestListingsByPhone(phone);
  }

  /// Get single listing by id
  Future<HarvestListing?> getListingById(String id) {
    return _db.getHarvestListingById(id);
  }

  /// Create new harvest listing
  Future<int> createListing({
    required String cropName,
    required String category,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    required String grade,
    required DateTime harvestDate,
    required String district,
    required String farmerName,
    required String farmerPhone,
    String? description,
    String? imagePath,
  }) {
    final companion = HarvestListingsCompanion.insert(
      id: const Uuid().v4(),
      cropName: cropName,
      category: category,
      quantity: quantity,
      unit: Value(unit),
      pricePerUnit: pricePerUnit,
      grade: Value(grade),
      harvestDate: harvestDate,
      district: district,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      description: Value(description),
      imagePath: Value(imagePath),
      isSold: const Value(false),
      createdAt: DateTime.now(),
    );

    return _db.insertHarvestListing(companion);
  }

  /// Mark listing as sold
  Future<int> markAsSold(String id) {
    return _db.markHarvestAsSold(id);
  }

  /// Delete listing
  Future<int> deleteListing(String id) {
    return _db.deleteHarvestListing(id);
  }

  /// Seed realistic initial Sri Lankan harvest listings if database is empty
  Future<void> _checkAndSeedInitialData() async {
    if (_seeded) return;
    _seeded = true;

    final existing = await _db.getAllHarvestListings();
    if (existing.isNotEmpty) return;

    final sampleListings = [
      HarvestListingsCompanion.insert(
        id: const Uuid().v4(),
        cropName: 'Organic Red Tomatoes (රතු තක්කාලි)',
        category: 'Vegetables',
        quantity: 350.0,
        unit: const Value('kg'),
        pricePerUnit: 140.0,
        grade: const Value('Organic'),
        harvestDate: DateTime.now().subtract(const Duration(hours: 8)),
        district: 'Dambulla',
        farmerName: 'Sunil Jayawardena',
        farmerPhone: '0771234567',
        description: const Value('Freshly picked organic pole tomatoes. Good shelf life, bulk transport can be arranged.'),
        isSold: const Value(false),
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      HarvestListingsCompanion.insert(
        id: const Uuid().v4(),
        cropName: 'Upcountry Carrots (නුවරඑළිය කැරට්)',
        category: 'Vegetables',
        quantity: 500.0,
        unit: const Value('kg'),
        pricePerUnit: 210.0,
        grade: const Value('Grade A'),
        harvestDate: DateTime.now().subtract(const Duration(hours: 14)),
        district: 'Nuwara Eliya',
        farmerName: 'Nimal Bandara',
        farmerPhone: '0719876543',
        description: const Value('Washed, graded A-quality juicy carrots. Suitable for supermarket distribution or wholesale.'),
        isSold: const Value(false),
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      HarvestListingsCompanion.insert(
        id: const Uuid().v4(),
        cropName: 'Dambulla Big Onions (ලොකු ළූණු)',
        category: 'Vegetables',
        quantity: 1200.0,
        unit: const Value('kg'),
        pricePerUnit: 260.0,
        grade: const Value('Grade A'),
        harvestDate: DateTime.now().subtract(const Duration(days: 1)),
        district: 'Matale',
        farmerName: 'Kamal Perera',
        farmerPhone: '0754433221',
        description: const Value('Dry, well-cured local big onions. Minimum order 50kg.'),
        isSold: const Value(false),
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      HarvestListingsCompanion.insert(
        id: const Uuid().v4(),
        cropName: 'Green Beans (බෝංචි)',
        category: 'Vegetables',
        quantity: 180.0,
        unit: const Value('kg'),
        pricePerUnit: 175.0,
        grade: const Value('Grade A'),
        harvestDate: DateTime.now().subtract(const Duration(hours: 5)),
        district: 'Badulla',
        farmerName: 'Sarath Weerasinghe',
        farmerPhone: '0785566778',
        description: const Value('Tender fresh bush beans directly from Welimada hills.'),
        isSold: const Value(false),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      HarvestListingsCompanion.insert(
        id: const Uuid().v4(),
        cropName: 'Jaffna Sweet Papaya (පැපොල්)',
        category: 'Fruits',
        quantity: 300.0,
        unit: const Value('kg'),
        pricePerUnit: 120.0,
        grade: const Value('Grade A'),
        harvestDate: DateTime.now().subtract(const Duration(hours: 10)),
        district: 'Jaffna',
        farmerName: 'K. Thivakar',
        farmerPhone: '0761122334',
        description: const Value('Red Lady sweet papayas, semi-ripe for 4 days transport.'),
        isSold: const Value(false),
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];

    for (final listing in sampleListings) {
      await _db.insertHarvestListing(listing);
    }
  }
}
