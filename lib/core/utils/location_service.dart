import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String district;
  final String country;
  final bool isAccurate;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.district,
    required this.country,
    this.isAccurate = true,
  });

  String get displayName {
    if (city.isNotEmpty && district.isNotEmpty && city.toLowerCase() != district.toLowerCase()) {
      return '$city, $district';
    } else if (city.isNotEmpty) {
      return '$city, $country';
    } else if (district.isNotEmpty) {
      return '$district, $country';
    }
    return country.isNotEmpty ? country : 'Sri Lanka';
  }

  factory UserLocation.fallback() {
    return const UserLocation(
      latitude: 6.9271, // Colombo default for Sri Lanka
      longitude: 79.8612,
      city: 'Colombo',
      district: 'Western Province',
      country: 'Sri Lanka',
      isAccurate: false,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  /// Backward compatible position fetcher
  Future<Position?> getCurrentLocation() async {
    try {
      final loc = await resolveLocation();
      return Position(
        latitude: loc.latitude,
        longitude: loc.longitude,
        timestamp: DateTime.now(),
        accuracy: loc.isAccurate ? 10.0 : 5000.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    } catch (e) {
      debugPrint('Error in getCurrentLocation: $e');
      return null;
    }
  }

  /// Complete location resolution: GPS -> IP Fallback -> Cache -> Default
  Future<UserLocation> resolveLocation({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedCity = prefs.getString('user_city');
      final cachedLat = prefs.getDouble('user_lat');
      final cachedLon = prefs.getDouble('user_lon');
      final cachedDistrict = prefs.getString('user_district');
      final cachedCountry = prefs.getString('user_country');

      if (cachedCity != null && cachedLat != null && cachedLon != null) {
        // Return cached location immediately for instant UI, but refresh in background
        unawaited(_fetchAndCacheRealLocation(prefs));
        return UserLocation(
          latitude: cachedLat,
          longitude: cachedLon,
          city: cachedCity,
          district: cachedDistrict ?? '',
          country: cachedCountry ?? 'Sri Lanka',
          isAccurate: true,
        );
      }
    }

    return await _fetchAndCacheRealLocation(prefs);
  }

  Future<UserLocation> _fetchAndCacheRealLocation(SharedPreferences prefs) async {
    double? latitude;
    double? longitude;
    bool isGPS = false;

    // 1. Try Hardware GPS
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        // First try last known for speed
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          latitude = lastPosition.latitude;
          longitude = lastPosition.longitude;
          isGPS = true;
        }

        // Then get fresh current position with 8s timeout
        try {
          Position currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 8),
          );
          latitude = currentPosition.latitude;
          longitude = currentPosition.longitude;
          isGPS = true;
        } catch (_) {
          // Timeout or error, lastPosition was already used if available
        }
      }
    } catch (e) {
      debugPrint('GPS detection failed: $e');
    }

    // 2. If GPS failed, try IP Geolocation fallback (works on emulators & when GPS is off)
    if (latitude == null || longitude == null) {
      final ipLoc = await _fetchIpLocation();
      if (ipLoc != null) {
        latitude = ipLoc['latitude'] as double?;
        longitude = ipLoc['longitude'] as double?;
        if (latitude != null && longitude != null) {
          final resolvedCity = ipLoc['city'] as String? ?? 'Sri Lanka';
          final resolvedRegion = ipLoc['region'] as String? ?? '';
          final loc = UserLocation(
            latitude: latitude,
            longitude: longitude,
            city: resolvedCity,
            district: resolvedRegion,
            country: 'Sri Lanka',
            isAccurate: false,
          );
          await _saveToPrefs(prefs, loc);
          return loc;
        }
      }
    }

    // 3. Reverse Geocode GPS coordinates to obtain city & district name
    if (latitude != null && longitude != null) {
      final geoInfo = await _reverseGeocode(latitude, longitude);
      final loc = UserLocation(
        latitude: latitude,
        longitude: longitude,
        city: geoInfo['city'] ?? 'Sri Lanka',
        district: geoInfo['district'] ?? '',
        country: geoInfo['country'] ?? 'Sri Lanka',
        isAccurate: isGPS,
      );
      await _saveToPrefs(prefs, loc);
      return loc;
    }

    // 4. Default fallback
    final fallback = UserLocation.fallback();
    await _saveToPrefs(prefs, fallback);
    return fallback;
  }

  Future<void> _saveToPrefs(SharedPreferences prefs, UserLocation loc) async {
    await prefs.setDouble('user_lat', loc.latitude);
    await prefs.setDouble('user_lon', loc.longitude);
    await prefs.setString('user_city', loc.city);
    await prefs.setString('user_district', loc.district);
    await prefs.setString('user_country', loc.country);
  }

  Future<Map<String, dynamic>?> _fetchIpLocation() async {
    try {
      final res = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final lat = data['latitude'] is num ? (data['latitude'] as num).toDouble() : null;
        final lon = data['longitude'] is num ? (data['longitude'] as num).toDouble() : null;
        final city = data['city'] as String?;
        final region = data['region'] as String?;
        if (lat != null && lon != null) {
          return {
            'latitude': lat,
            'longitude': lon,
            'city': city,
            'region': region,
          };
        }
      }
    } catch (e) {
      debugPrint('IP location error: $e');
    }
    return null;
  }

  Future<Map<String, String>> _reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        String city = data['city'] as String? ?? data['locality'] as String? ?? '';
        String district = data['principalSubdivision'] as String? ?? '';
        String country = data['countryName'] as String? ?? 'Sri Lanka';

        // Clean up district or locality if empty
        if (city.isEmpty && district.isNotEmpty) {
          city = district;
        }

        return {
          'city': city.isNotEmpty ? city : 'Sri Lanka',
          'district': district,
          'country': country,
        };
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }

    return {
      'city': 'Sri Lanka',
      'district': '',
      'country': 'Sri Lanka',
    };
  }
}

class UserLocationNotifier extends AsyncNotifier<UserLocation> {
  @override
  Future<UserLocation> build() async {
    final service = ref.read(locationServiceProvider);
    return await service.resolveLocation();
  }

  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(locationServiceProvider);
      return await service.resolveLocation(forceRefresh: true);
    });
  }

  Future<void> setManualLocation(UserLocation manual) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_lat', manual.latitude);
    await prefs.setDouble('user_lon', manual.longitude);
    await prefs.setString('user_city', manual.city);
    await prefs.setString('user_district', manual.district);
    await prefs.setString('user_country', manual.country);
    state = AsyncValue.data(manual);
  }
}

final userLocationProvider = AsyncNotifierProvider<UserLocationNotifier, UserLocation>(() {
  return UserLocationNotifier();
});
