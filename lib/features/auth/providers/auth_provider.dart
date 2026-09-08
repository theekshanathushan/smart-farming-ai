import 'package:firebase_auth/firebase_auth.dart' hide AuthState;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStateStatus { initial, loading, otpSent, error, success }

class AuthState {
  final AuthStateStatus status;
  final String? errorMessage;
  final String? verificationId;
  final String? phoneNumber;
  final String? name;

  const AuthState({
    this.status = AuthStateStatus.initial,
    this.errorMessage,
    this.verificationId,
    this.phoneNumber,
    this.name,
  });

  AuthState copyWith({
    AuthStateStatus? status,
    String? errorMessage,
    String? verificationId,
    String? phoneNumber,
    String? name,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  AuthNotifier() : super(const AuthState());

  String _formatPhoneNumber(String phone) {
    String formatted = phone.trim();
    
    // Fix common mistake: user types +77... instead of +9477... or 077...
    // Sri Lankan mobile numbers without country code are 9 digits long (10 chars with '+')
    if (formatted.startsWith('+') && formatted.length == 10 && !formatted.startsWith('+94')) {
      formatted = formatted.substring(1);
    }
    
    if (formatted.startsWith('0')) {
      formatted = formatted.substring(1);
    }
    
    if (!formatted.startsWith('+')) {
      // Assuming Sri Lanka country code based on requirement
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

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (firebase.PhoneAuthCredential credential) async {
          // Auto-resolution (Android only usually)
          try {
            await _auth.signInWithCredential(credential);
            state = state.copyWith(status: AuthStateStatus.success);
          } catch (e) {
            state = state.copyWith(
              status: AuthStateStatus.error,
              errorMessage: 'Auto verification failed: ${e.toString()}',
            );
          }
        },
        verificationFailed: (firebase.FirebaseAuthException e) {
          state = state.copyWith(
            status: AuthStateStatus.error,
            errorMessage: e.message ?? 'Verification failed',
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            status: AuthStateStatus.otpSent,
            verificationId: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          state = state.copyWith(
            verificationId: verificationId,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> verifyOTP(String otpCode) async {
    state = state.copyWith(status: AuthStateStatus.loading);
    try {
      if (state.verificationId == null) {
        throw Exception('Verification ID is missing. Please request OTP again.');
      }

      firebase.PhoneAuthCredential credential = firebase.PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: otpCode.trim(),
      );

      await _auth.signInWithCredential(credential);

      state = state.copyWith(status: AuthStateStatus.success);
    } on firebase.FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: e.message ?? 'Invalid OTP',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void resetState() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
