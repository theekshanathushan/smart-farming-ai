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
      errorMessage: errorMessage, // We want to clear error message if not provided
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // Placeholder for sending OTP
  Future<void> sendOTP(String phoneNumber, {String? name}) async {
    state = state.copyWith(status: AuthStateStatus.loading, phoneNumber: phoneNumber, name: name);
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate a "No Internet" error for demonstration if number starts with 000
      if (phoneNumber.startsWith('000')) {
        throw Exception('No Internet Connection');
      }

      // TODO: Implement actual API call to send OTP here
      // final response = await api.sendOtp(phone: phoneNumber, name: name);

      // Simulate success
      state = state.copyWith(
        status: AuthStateStatus.otpSent,
        verificationId: 'dummy_verification_id_123',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Placeholder for verifying OTP
  Future<void> verifyOTP(String otpCode) async {
    state = state.copyWith(status: AuthStateStatus.loading);
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate invalid OTP
      if (otpCode != '123456') { // Hardcoded for demo
        throw Exception('Invalid OTP. Please try again.');
      }

      // TODO: Implement actual API call to verify OTP here
      // final response = await api.verifyOtp(verificationId: state.verificationId, otp: otpCode);

      // Simulate success
      state = state.copyWith(status: AuthStateStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
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
