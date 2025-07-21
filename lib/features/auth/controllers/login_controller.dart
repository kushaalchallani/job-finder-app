import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      isSocialLoading: isSocialLoading ?? this.isSocialLoading,
      error: error,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(const LoginState()) {
    // print('LoginController created');
  }
  @override
  void dispose() {
    // print('LoginController disposed');
    super.dispose();
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final error = await AuthService.signInWithEmail(
      email: email,
      password: password,
    );
    state = state.copyWith(isLoading: false, error: error);
    return error == null;
  }

  Future<bool> signInWithSocial({
    required OAuthProvider provider,
    required BuildContext context,
  }) async {
    state = state.copyWith(isSocialLoading: true, error: null);
    final error = await AuthService.signInWithSocial(
      provider: provider,
      context: context,
    );
    state = state.copyWith(isSocialLoading: false, error: error);
    return error == null;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>(
      (ref) => LoginController(),
    );
