import 'package:firebase_auth/firebase_auth.dart' as firebase;
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

  const AuthState({
    this.status = AuthStateStatus.initial,
    this.errorMessage,
    this.verificationId,
    this.phoneNumber,
    this.name,
    this.isLoggedIn = false,
    this.profileImagePath,
  });

  AuthState copyWith({
    AuthStateStatus? status,
    String? errorMessage,
    String? verificationId,
    String? phoneNumber,
    String? name,
    bool? isLoggedIn,
    String? profileImagePath,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      profileImagePath: profileImagePath ?? this.profileImagePath,
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
      state = state.copyWith(
        isLoggedIn: true,
        name: name,
        phoneNumber: phone ?? _auth.currentUser?.phoneNumber,
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

  Future<void> sendOTP(String phoneNumber, {String? name}) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    state = state.copyWith(
      status: AuthStateStatus.loading,
      phoneNumber: formattedPhone,
      name: name,
    );

    // MOCK OTP FLOW TO BYPASS FIREBASE ERRORS DURING UI TESTING
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      status: AuthStateStatus.otpSent,
      verificationId: 'mock_verification_id',
    );
  }

  Future<void> verifyOTP(String otpCode) async {
    state = state.copyWith(status: AuthStateStatus.loading);
    
    // MOCK OTP VERIFICATION
    await Future.delayed(const Duration(seconds: 1));
    
    if (otpCode.isNotEmpty) { // Accept any OTP for testing
      await _saveSession(state.phoneNumber ?? '', state.name);
      state = state.copyWith(status: AuthStateStatus.success, isLoggedIn: true);
    } else {
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: 'Invalid OTP',
      );
    }
  }

  Future<void> _saveSession(String phone, String? name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', phone);
    if (name != null) {
      await prefs.setString('userName', name);
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
    await prefs.clear();
    await _auth.signOut();
    state = const AuthState();
  }

  void resetState() {
    // only reset auth flow status, keep user session info
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
