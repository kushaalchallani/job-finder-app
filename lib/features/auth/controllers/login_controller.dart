import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/providers/auth_provider.dart';
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
    final error = await AuthEmailService.signInWithEmail(
      email: email,
      password: password,
    );

    if (error != null) {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }

    // Fetch user role manually from Supabase after login
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not found');
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      final role = profile?['role'] as String?;
      final context = navigatorKey.currentContext;

      if (role == 'seeker') {
        context?.go('/seeker/home');
      } else if (role == 'recruiter') {
        context?.go('/recruiter/home');
      } else {
        context?.go('/home');
      }
    } catch (e) {
      debugPrint('Failed to fetch user role: $e');
      navigatorKey.currentContext?.go('/home');
    }

    state = state.copyWith(isLoading: false);
    return true;
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

    if (error != null) return false;

    // 🟢 FLASH WORKS because this happens after widget is ready
    final session = Supabase.instance.client.auth.currentSession;
    final role = session?.user.userMetadata?['role'];

    if (role == 'recruiter') {
      context.go('/recruiter-home');
    } else {
      context.go('/home');
    }

    return true;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>(
      (ref) => LoginController(),
    );
