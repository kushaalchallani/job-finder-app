import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/auth/services/auth_email_service.dart';
import 'package:job_finder_app/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class SignUpState {
  final bool isLoading;
  final bool isSocialLoading;
  final String? error;

  const SignUpState({
    this.isLoading = false,
    this.isSocialLoading = false,
    this.error,
  });

  SignUpState copyWith({
    bool? isLoading,
    bool? isSocialLoading,
    String? error,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      isSocialLoading: isSocialLoading ?? this.isSocialLoading,
      error: error,
    );
  }
}

class SignUpController extends StateNotifier<SignUpState> {
  SignUpController() : super(const SignUpState());

  Future<bool> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await AuthEmailService.signUpWithEmail(
      fullName: fullName,
      email: email,
      password: password,
    );
    state = state.copyWith(isLoading: false);

    if (!success) {
      setError("Signup failed. Please check your details and try again.");
      return false;
    }

    clearError();
    return true;
  }

  Future<bool> socialSignUp({
    required OAuthProvider provider,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) async {
    state = state.copyWith(isSocialLoading: true, error: null);
    final error = await AuthService.socialSignUp(
      provider: provider,
      context: context,
      onSuccess: onSuccess,
    );
    state = state.copyWith(isSocialLoading: false, error: error);
    return error == null;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }
}

final signUpControllerProvider =
    StateNotifierProvider<SignUpController, SignUpState>(
      (ref) => SignUpController(),
    );
