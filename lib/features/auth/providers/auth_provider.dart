import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStateStatus { initial, loading, otpSent, error, success }

class AuthState {
  final AuthStateStatus status;
  final String? errorMessage;
  final String? verificationId;
  final String? phoneNumber;
  final String? name;
  final bool isLoggedIn;
  final String? profileImagePath;
  final bool isRegistration;

  const AuthState({
    this.status = AuthStateStatus.initial,
    this.errorMessage,
    this.verificationId,
    this.phoneNumber,
    this.name,
    this.isLoggedIn = false,
    this.profileImagePath,
    this.isRegistration = false,
  });

  AuthState copyWith({
    AuthStateStatus? status,
    String? errorMessage,
    String? verificationId,
    String? phoneNumber,
    String? name,
    bool? isLoggedIn,
    String? profileImagePath,
    bool clearProfileImage = false,
    bool? isRegistration,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      profileImagePath: clearProfileImage ? null : (profileImagePath ?? this.profileImagePath),
      isRegistration: isRegistration ?? this.isRegistration,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  AuthNotifier([AuthState? initialState]) : super(initialState ?? const AuthState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final phone = prefs.getString('userPhone') ?? _auth.currentUser?.phoneNumber;

    if (isLoggedIn && phone != null && phone.trim().isNotEmpty) {
      final activePhone = phone.trim();
      final name = prefs.getString('registered_user_name_$activePhone') ?? prefs.getString('userName');
      var profileImagePath = prefs.getString('user_profile_photo_$activePhone') ?? prefs.getString('profileImagePath');

      if (profileImagePath != null) {
        final f = File(profileImagePath);
        if (!await f.exists()) {
          profileImagePath = null;
        }
      }

      await _ensureUserRegisteredLocally(activePhone, name ?? '');

      state = state.copyWith(
        isLoggedIn: true,
        name: name,
        phoneNumber: activePhone,
        profileImagePath: profileImagePath,
      );
    } else if (!isLoggedIn) {
      state = const AuthState();
    }
  }

  String _formatPhoneNumber(String phone) {
    String formatted = phone.trim();
    if (formatted.startsWith('+') && formatted.length == 10 && !formatted.startsWith('+94')) {
      formatted = formatted.substring(1);
    }
    if (formatted.startsWith('0')) {
      formatted = formatted.substring(1);
    }
    if (!formatted.startsWith('+')) {
      formatted = '+94$formatted';
    }
    return formatted;
  }

  /// Ensure registered phone and name are recorded in persistent local storage
  Future<void> _ensureUserRegisteredLocally(String phone, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final registered = prefs.getStringList('registered_phone_numbers') ?? [];
    if (!registered.contains(phone)) {
      registered.add(phone);
      await prefs.setStringList('registered_phone_numbers', registered);
    }
    if (name.trim().isNotEmpty) {
      await prefs.setString('registered_user_name_$phone', name.trim());
    }
  }

  /// Checks if a phone number exists in local registry or cloud Firestore
  Future<Map<String, String>?> checkUserRegistration(String formattedPhone) async {
    final prefs = await SharedPreferences.getInstance();
    final registered = prefs.getStringList('registered_phone_numbers') ?? [];
    final localName = prefs.getString('registered_user_name_$formattedPhone');

    // 1. Check local registry (offline-first & instantaneous)
    if (registered.contains(formattedPhone)) {
      return {'phone': formattedPhone, 'name': localName ?? ''};
    }

    // 2. Check Firestore (cloud-synced accounts across devices)
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(formattedPhone)
          .get()
          .timeout(const Duration(seconds: 4));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final cloudName = (data['name'] as String?) ?? '';
        await _ensureUserRegisteredLocally(formattedPhone, cloudName);
        return {'phone': formattedPhone, 'name': cloudName};
      }
    } catch (_) {
      // Network unavailable or offline - rely on local registry
    }

    return null;
  }

  Future<void> sendOTP(
    String phoneNumber, {
    String? name,
    bool isLogin = true,
    String language = 'si',
  }) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    state = state.copyWith(status: AuthStateStatus.loading, errorMessage: null);

    // Strict registration verification
    final existingUser = await checkUserRegistration(formattedPhone);

    if (isLogin) {
      // Must be registered before logging in
      if (existingUser == null) {
        final error = language == 'si'
            ? 'මෙම දුරකථන අංකය ලියාපදිංචි කර නොමැත. කරුණාකර පළමුව ලියාපදිංචි වන්න.'
            : (language == 'ta'
                ? 'இந்த தொலைபேசி எண் பதிவு செய்யப்படவில்லை. முதலில் பதிவு செய்யவும்.'
                : 'This phone number is not registered. Please register first.');
        state = state.copyWith(
          status: AuthStateStatus.error,
          errorMessage: error,
        );
        return;
      }

      final resolvedName = (existingUser['name'] != null && existingUser['name']!.isNotEmpty)
          ? existingUser['name']!
          : (name != null && name.trim().isNotEmpty ? name.trim() : state.name);

      state = state.copyWith(
        phoneNumber: formattedPhone,
        name: resolvedName,
        isRegistration: false,
      );
    } else {
      // Register mode: Must not already exist
      if (existingUser != null) {
        final error = language == 'si'
            ? 'මෙම දුරකථන අංකය දැනටමත් ලියාපදිංචි කර ඇත. කරුණාකර ලොග් වන්න.'
            : (language == 'ta'
                ? 'இந்த தொலைபேசி எண் ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது. உள்நுழையவும்.'
                : 'This phone number is already registered. Please log in.');
        state = state.copyWith(
          status: AuthStateStatus.error,
          errorMessage: error,
        );
        return;
      }

      state = state.copyWith(
        phoneNumber: formattedPhone,
        name: (name != null && name.trim().isNotEmpty) ? name.trim() : 'Farmer',
        isRegistration: true,
      );
    }

    // MOCK OTP FLOW TO BYPASS FIREBASE SMS RESTRICTIONS DURING TESTING
    await Future.delayed(const Duration(milliseconds: 700));
    state = state.copyWith(
      status: AuthStateStatus.otpSent,
      verificationId: 'mock_verification_id',
    );
  }

  Future<void> verifyOTP(String otpCode) async {
    state = state.copyWith(status: AuthStateStatus.loading);

    // MOCK OTP VERIFICATION
    await Future.delayed(const Duration(milliseconds: 600));

    if (otpCode.isNotEmpty) {
      final phone = state.phoneNumber ?? '';
      final prefs = await SharedPreferences.getInstance();

      // Resolve user's persistent name (specific to this phone)
      String name = prefs.getString('registered_user_name_$phone') ?? (state.name ?? '');
      if (name.trim().isEmpty) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(phone)
              .get()
              .timeout(const Duration(seconds: 4));
          if (doc.exists && doc.data() != null) {
            name = (doc.data()!['name'] as String?) ?? '';
          }
        } catch (_) {}
      }
      if (name.trim().isEmpty) {
        name = 'Farmer';
      }

      // Resolve user's persistent profile photo (specific to this phone)
      String? photoPath = prefs.getString('user_profile_photo_$phone');
      if (photoPath != null) {
        final f = File(photoPath);
        if (!await f.exists()) {
          photoPath = null;
        }
      }

      // If photoPath not found locally, check Firestore
      if (photoPath == null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(phone)
              .get()
              .timeout(const Duration(seconds: 4));
          if (doc.exists && doc.data() != null) {
            final cloudPhoto = doc.data()!['profileImagePath'] as String?;
            if (cloudPhoto != null && cloudPhoto.isNotEmpty) {
              final f = File(cloudPhoto);
              if (await f.exists()) {
                photoPath = cloudPhoto;
                await prefs.setString('user_profile_photo_$phone', photoPath);
              }
            }
          }
        } catch (_) {}
      }

      // Save registry and cloud records
      await _ensureUserRegisteredLocally(phone, name);
      try {
        await FirebaseFirestore.instance.collection('users').doc(phone).set({
          'phone': phone,
          'name': name,
          if (photoPath != null) 'profileImagePath': photoPath,
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}

      await _saveSession(phone, name, photoPath);

      state = state.copyWith(
        status: AuthStateStatus.success,
        isLoggedIn: true,
        phoneNumber: phone,
        name: name,
        profileImagePath: photoPath,
      );
    } else {
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: 'Invalid OTP',
      );
    }
  }

  Future<void> updateName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', trimmed);
      if (state.phoneNumber != null) {
        await prefs.setString('registered_user_name_${state.phoneNumber}', trimmed);
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(state.phoneNumber)
              .set({'name': trimmed, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
        } catch (_) {}
      }
      state = state.copyWith(name: trimmed);
    }
  }

  Future<void> _saveSession(String phone, String? name, String? profileImagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', phone);
    if (name != null && name.trim().isNotEmpty) {
      await prefs.setString('userName', name.trim());
      await prefs.setString('registered_user_name_$phone', name.trim());
      state = state.copyWith(name: name.trim());
    }
    if (profileImagePath != null && profileImagePath.trim().isNotEmpty) {
      await prefs.setString('profileImagePath', profileImagePath.trim());
      await prefs.setString('user_profile_photo_$phone', profileImagePath.trim());
      state = state.copyWith(profileImagePath: profileImagePath.trim());
    } else {
      await prefs.remove('profileImagePath');
    }
  }

  Future<void> updateProfileImage(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = state.phoneNumber;

    if (path == null) {
      await prefs.remove('profileImagePath');
      if (phone != null) {
        await prefs.remove('user_profile_photo_$phone');
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(phone)
              .set({'profileImagePath': null}, SetOptions(merge: true));
        } catch (_) {}
      }
      state = state.copyWith(clearProfileImage: true);
      return;
    }

    // Persist picked image permanently into application documents directory
    String savedPath = path;
    try {
      final file = File(path);
      if (await file.exists()) {
        final docDir = await getApplicationDocumentsDirectory();
        final profileDir = Directory(p.join(docDir.path, 'profile_photos'));
        if (!await profileDir.exists()) {
          await profileDir.create(recursive: true);
        }

        final sanitizedPhone = (phone ?? 'user').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final ext = p.extension(path).isNotEmpty ? p.extension(path) : '.jpg';
        final destFile = File(p.join(
          profileDir.path,
          'profile_${sanitizedPhone}_${DateTime.now().millisecondsSinceEpoch}$ext',
        ));

        // Delete old persistent photo if different
        final oldPath = state.profileImagePath;
        if (oldPath != null && oldPath != path) {
          try {
            final oldFile = File(oldPath);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          } catch (_) {}
        }

        await file.copy(destFile.path);
        savedPath = destFile.path;
      }
    } catch (_) {
      savedPath = path;
    }

    // Save to active session and user-specific persistent storage
    await prefs.setString('profileImagePath', savedPath);
    if (phone != null) {
      await prefs.setString('user_profile_photo_$phone', savedPath);
      try {
        await FirebaseFirestore.instance.collection('users').doc(phone).set({
          'profileImagePath': savedPath,
          'hasProfilePhoto': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }

    state = state.copyWith(profileImagePath: savedPath);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear only session data, NEVER touch user-specific records (e.g. user_profile_photo_$phone or registered_user_name_$phone)
    await prefs.remove('isLoggedIn');
    await prefs.remove('userName');
    await prefs.remove('userPhone');
    await prefs.remove('profileImagePath');

    // Clean up any guest database files to ensure 100% privacy
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final guestDb = File(p.join(docDir.path, 'db_guest.sqlite'));
      if (await guestDb.exists()) {
        await guestDb.delete();
      }
      final guestWal = File(p.join(docDir.path, 'db_guest.sqlite-wal'));
      if (await guestWal.exists()) {
        await guestWal.delete();
      }
      final guestShm = File(p.join(docDir.path, 'db_guest.sqlite-shm'));
      if (await guestShm.exists()) {
        await guestShm.delete();
      }
    } catch (_) {}

    try {
      await _auth.signOut();
    } catch (_) {}

    state = const AuthState();
  }

  void resetState() {
    state = state.copyWith(
      status: AuthStateStatus.initial,
      errorMessage: null,
      verificationId: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

