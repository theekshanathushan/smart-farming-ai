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
    bool? isRegistration,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isRegistration: isRegistration ?? this.isRegistration,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  AuthNotifier() : super(const AuthState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final name = prefs.getString('userName');
    final phone = prefs.getString('userPhone');
    final profileImagePath = prefs.getString('profileImagePath');

    // Also check firebase auth
    final isFirebaseLoggedIn = _auth.currentUser != null;

    if (isLoggedIn || isFirebaseLoggedIn) {
      final activePhone = phone ?? _auth.currentUser?.phoneNumber;
      if (activePhone != null && activePhone.trim().isNotEmpty) {
        await _ensureUserRegisteredLocally(activePhone.trim(), name ?? '');
      }

      state = state.copyWith(
        isLoggedIn: true,
        name: name,
        phoneNumber: activePhone,
        profileImagePath: profileImagePath,
      );
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
      final name = state.name ?? '';

      // Register / update in local and cloud records
      await _ensureUserRegisteredLocally(phone, name);
      try {
        await FirebaseFirestore.instance.collection('users').doc(phone).set({
          'phone': phone,
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}

      await _saveSession(phone, name);
      state = state.copyWith(status: AuthStateStatus.success, isLoggedIn: true);
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
              .set({'name': trimmed}, SetOptions(merge: true));
        } catch (_) {}
      }
      state = state.copyWith(name: trimmed);
    }
  }

  Future<void> _saveSession(String phone, String? name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', phone);
    if (name != null && name.trim().isNotEmpty) {
      await prefs.setString('userName', name.trim());
      state = state.copyWith(name: name.trim());
    }
  }

  Future<void> updateProfileImage(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove('profileImagePath');
    } else {
      await prefs.setString('profileImagePath', path);
    }
    state = state.copyWith(profileImagePath: path);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear only session data, preserve registered accounts and preferences
    await prefs.remove('isLoggedIn');
    await prefs.remove('userName');
    await prefs.remove('userPhone');
    await prefs.remove('profileImagePath');
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
