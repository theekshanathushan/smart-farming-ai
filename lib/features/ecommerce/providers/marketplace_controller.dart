import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/local_db/app_database.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/harvest_listing_repository.dart';

enum MarketplaceTab { browse, myListings }

class MarketplaceState {
  final List<HarvestListing> allListings;
  final List<HarvestListing> myListings;
  final bool isLoading;
  final MarketplaceTab currentTab;
  final String searchQuery;
  final String selectedCategory;

  const MarketplaceState({
    this.allListings = const [],
    this.myListings = const [],
    this.isLoading = true,
    this.currentTab = MarketplaceTab.browse,
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  List<HarvestListing> get filteredBrowseListings {
    return allListings.where((item) {
      if (item.isSold) return false;

      // Category filter
      if (selectedCategory != 'All' && item.category.toLowerCase() != selectedCategory.toLowerCase()) {
        return false;
      }

      // Search query filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesCrop = item.cropName.toLowerCase().contains(query);
        final matchesDistrict = item.district.toLowerCase().contains(query);
        final matchesFarmer = item.farmerName.toLowerCase().contains(query);
        if (!matchesCrop && !matchesDistrict && !matchesFarmer) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<HarvestListing> get filteredMyListings {
    if (searchQuery.isEmpty) return myListings;
    final query = searchQuery.toLowerCase();
    return myListings.where((item) {
      return item.cropName.toLowerCase().contains(query) ||
             item.district.toLowerCase().contains(query);
    }).toList();
  }

  MarketplaceState copyWith({
    List<HarvestListing>? allListings,
    List<HarvestListing>? myListings,
    bool? isLoading,
    MarketplaceTab? currentTab,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return MarketplaceState(
      allListings: allListings ?? this.allListings,
      myListings: myListings ?? this.myListings,
      isLoading: isLoading ?? this.isLoading,
      currentTab: currentTab ?? this.currentTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final HarvestListingRepository _repository;
  final Ref _ref;

  MarketplaceNotifier(this._repository, this._ref) : super(const MarketplaceState()) {
    loadListings();
  }

  String get _currentFarmerPhone {
    final auth = _ref.read(authProvider);
    return auth.phoneNumber ?? '0771234567'; // Fallback to current phone or demo
  }

  Future<void> loadListings() async {
    state = state.copyWith(isLoading: true);
    try {
      final all = await _repository.getAllListings();
      final mine = await _repository.getMyListings(_currentFarmerPhone);

      state = state.copyWith(
        allListings: all,
        myListings: mine,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setTab(MarketplaceTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> createListing({
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
  }) async {
    await _repository.createListing(
      cropName: cropName,
      category: category,
      quantity: quantity,
      unit: unit,
      pricePerUnit: pricePerUnit,
      grade: grade,
      harvestDate: harvestDate,
      district: district,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      description: description,
      imagePath: imagePath,
    );
    await loadListings();
  }

  Future<void> markAsSold(String id) async {
    await _repository.markAsSold(id);
    await loadListings();
  }

  Future<void> deleteListing(String id) async {
    await _repository.deleteListing(id);
    await loadListings();
  }
}

final marketplaceProvider = StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  final repo = ref.watch(harvestListingRepositoryProvider);
  return MarketplaceNotifier(repo, ref);
});
