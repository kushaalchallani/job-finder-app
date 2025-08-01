// ignore_for_file: use_build_context_synchronously

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/auth/services/auth_email_service.dart';
import 'package:job_finder_app/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class LoginState {
  final bool isLoading;
  final bool isSocialLoading;
  final String? error;

  const LoginState({
    this.isLoading = false,
    this.isSocialLoading = false,
    this.error,
  });

  LoginState copyWith({bool? isLoading, bool? isSocialLoading, String? error}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSocialLoading: isLoading ?? this.isSocialLoading,
      error: error,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(const LoginState());

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final error = await AuthEmailService.signInWithEmail(
      email: email,
      password: password,
    );

    if (error != null) {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }

    // Let the auth provider handle navigation
    // The authRedirectProvider will automatically redirect based on user role
    state = state.copyWith(isLoading: false);
    return true;
  }

  //  SIMPLIFIED: Social login now just initiates OAuth, validation handled by DeepLinkHandler
  Future<bool> signInWithSocial({
    required OAuthProvider provider,
    required BuildContext context,
  }) async {
    state = state.copyWith(isSocialLoading: true, error: null);

    try {
      await AuthService.signInWithSocial(provider: provider, context: context);

      // 🔧 REMOVED: All validation logic moved to DeepLinkHandler
      // The deep link handler will handle the OAuth callback and show appropriate messages

      state = state.copyWith(isSocialLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSocialLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>(
      (ref) => LoginController(),
    );
